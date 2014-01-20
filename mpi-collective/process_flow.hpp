#ifndef MASTER_HPP
#define	MASTER_HPP

#include <vector>

class ProcessFlow {
    int world_size, 
        world_rank, 
        matrix_rows, 
        matrix_cols;
    std::vector<float> matrix,
                       compare_vector;
    
    /**
     * Parses human-readable representation of matrix and saves its data to current object.
     * 
     * @param string_matrix String that stores list of rows in the following format: x1,y1,...;x2,y2,...;...
     * @param string_vector String that stores vector to compare to in the following format: x1,y1,...
     */
    void parse_input(const char* string_matrix, const char* string_vector);
    
    bool is_master();
    bool check(int argc);
    
    /**
     * Calculates data that will be send to each process.
     * 
     * @param data_per_process Array with data count for each process.
     * @param displacement Data offset for each process.
     */
    void displace_get(int *data_per_process, int *displacement);
    
    /**
     * Calculates a scalar product of each input vector on vector to compare and returns array with results.
     * 
     * @param vectors Pointer to vectors.
     * @param size Size of the data in vector variable.
     * @param scalar_product Results array.
     */
    void scalar_product(float const *vectors, int size, float *scalar_product);
    
public:
    ProcessFlow ();
    /**
     * Controls master process.
     * 
     * @param argc Value from main() function.
     * @param argv Value from main() function.
     */
    bool run(int argc, char **argv);
};

#endif	/* MASTER_HPP */

