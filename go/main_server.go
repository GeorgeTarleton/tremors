package main

import (
	"encoding/json"
	"github.com/gocarina/gocsv"
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strconv"
)

func main() {
	//ch := make(chan PiDataValue)

	file, err := os.OpenFile("data.csv", os.O_RDWR | os.O_CREATE, os.ModePerm)
	if err != nil {
			log.Println(err)
			return
	}
	defer file.Close()

	data := []PiDataValue{}

	err = gocsv.UnmarshalFile(file, &data)
	if err != nil {
		panic(err)
	}

	log.Println(data)


	r := mux.NewRouter()
	r.HandleFunc("/", func (w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		switch r.Method {
			case "POST":
				body, err := ioutil.ReadAll(r.Body)

				if err != nil {
					log.Printf("Error reading body: %v", err)
					http.Error(w, `{"message": "Couldn't read body."}`, http.StatusBadRequest)
					return
				}

				var x PiDataValue
				err = json.Unmarshal(body, &x)
				if err != nil {
					log.Printf("Error parsing body: %v", err)
					http.Error(w, `{"message": "Couldn't parse body."}`, http.StatusBadRequest)
					return
				}

				err = gocsv.MarshalWithoutHeaders([]PiDataValue{x}, file)
				if err != nil {
					log.Printf("Error marshalling data: %v", err)
					http.Error(w, `{"message": "Failed to write data."}`, http.StatusInternalServerError)
					return
				}

				data = append(data, x)

        w.WriteHeader(http.StatusCreated)
        w.Write([]byte(`{"message": "Data received successfully."}`))
			case "GET":
				d, err := json.Marshal(map[string][]PiDataValue { "data": data })
				if err != nil {
					log.Printf("Error serialising data: %v", err)
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

	r.HandleFunc("/user/{uid}", func (w http.ResponseWriter, r *http.Request) {
		pathParams := mux.Vars(r)
		w.Header().Set("Content-Type", "application/json")
		
		uid := -1
		var err error
		if val, ok := pathParams["uid"]; ok {
			uid, err = strconv.Atoi(val)
			if err != nil {
				w.WriteHeader(http.StatusInternalServerError)
				w.Write([]byte(`{"message": "need a number"}`))
        return
			}
		}

		matching := []PiDataValue{}
		for _, pdv := range data {
			if pdv.Uid == uid {
				matching = append(matching, pdv)
			}
		}

		d, err := json.Marshal(map[string][]PiDataValue { "data": matching })
		if err != nil {
			log.Printf("Error serialising data: %v", err)
			http.Error(w, `{"message": "Failed to serialise data."}`, http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		w.Write(d)
	})

	http.ListenAndServe(":8080", r)
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
