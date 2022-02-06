package main

import (
	"encoding/json"
	"github.com/gocarina/gocsv"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

func main() {
	//ch := make(chan PiDataValue)

	file, err := os.OpenFile("data.csv", os.O_RDWR | os.O_CREATE, os.ModePerm)
	if err != nil {
			fmt.Println(err)
			return
	}
	defer file.Close()

	data := []PiDataValue{}

	err = gocsv.UnmarshalFile(file, &data)
	if err != nil {
		panic(err)
	}

	fmt.Println(data)


	http.HandleFunc("/", func (w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		switch r.Method {
			case "POST":
				body, err := ioutil.ReadAll(r.Body)

				if err != nil {
					fmt.Printf("Error reading body: %v", err)
					http.Error(w, `{"message": "Couldn't read body."}`, http.StatusBadRequest)
					return
				}

				var x PiDataValue
				err = json.Unmarshal(body, &x)
				if err != nil {
					fmt.Printf("Error parsing body: %v", err)
					http.Error(w, `{"message": "Couldn't parse body."}`, http.StatusBadRequest)
					return
				}

				err = gocsv.MarshalWithoutHeaders([]PiDataValue{x}, file)
				if err != nil {
					fmt.Printf("Error marshalling data: %v", err)
					http.Error(w, `{"message": "Failed to write data."}`, http.StatusInternalServerError)
					return
				}

				data = append(data, x)

        w.WriteHeader(http.StatusCreated)
        w.Write([]byte(`{"message": "Data received successfully."}`))
			case "GET":
				d, err := json.Marshal(map[string][]PiDataValue { "data": data })
				if err != nil {
					fmt.Printf("Error serialising data: %v", err)
					http.Error(w, `{"message": "Failed to serialise data."}`, http.StatusInternalServerError)
					return
				}

        w.WriteHeader(http.StatusOK)
        w.Write(d)
			default:
        w.WriteHeader(http.StatusNotFound)
        w.Write([]byte(`{"message": "not found"}`))
		}
	})

	http.ListenAndServe(":8080", nil)
}

type PiDataValue struct {
	Uid int `json:"uid" csv:"uid"`
	Shakiness int `json:"shakiness" csv:"shakiness"`
	Concern int `json:"concern" csv:"concern"`
	Stddev float64 `json:"stddev" csv:"stddev"`
	Day int `json:"day" csv:"day"`
	Month int `json:"month" csv:"month"`
	Year int `json:"year" csv:"year"`
}
