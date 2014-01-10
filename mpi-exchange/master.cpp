#include <cstdlib>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

using namespace std;

void parse_input(const char* string_vectors, vector< vector<float> > &vectors) {
    string data(string_vectors);

    stringstream ss1(data);
    string string_vector, number;
    while (getline(ss1, string_vector, ';')) {
        stringstream ss2(string_vector);
        vectors.push_back(vector<float>());
        while (getline(ss2, number, ',')) {
            vectors[vectors.size()-1].push_back(atof(number.c_str()));
        }
    }
}

void start_master(char** argv) {
    vector< vector<float> > vectors;
    parse_input(argv[1],vectors);
}