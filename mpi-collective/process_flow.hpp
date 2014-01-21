#ifndef MASTER_HPP
#define	MASTER_HPP

#include <vector>
#include <string>

/**
 * Controls process flow.
 */
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
    
    /**
     * Checks if current process is master process.
     * 
     * @return true if master process, false otherwise.
     */
    bool is_master();
    
    /**
     * Initial check.
     * 
     * @param argc Number of command line arguments.
     * @return true on success, false otherwise.
     */
    bool check(int argc);
    
    /**
     * Converts std::vector of floats to human-readable std::string.
     * 
     * @param input_vector Vector of floats to convert.
     * @return Human-readable vector representation.
     */
    std::string vector_to_human(std::vector<float> &input_vector);
    
    /**
     * Converts floats vector to vector of floats vectors.
     * 
     * @param array Floats array.
     * @param count Number of elements in each vector.
     * @param array Number of vectors.
     * @return Vector of floats vectors.
     */
    std::vector< std::vector<float> > array_to_vector(float const *array, int count, int total);
    
    /**
     * Calculates data that will be send to each process.
     * 
     * @param rows_per_process Number of elements per process. Get it from ProcessFlow::get_rows_per_process().
     * @param size Size of each element.
     * @param data_per_process Output array where index is process number and value is data size.
     * @param displacement Output array where index is process number and value is data offset.
     */
    void get_displace(int const *rows_per_process, int size, int *data_per_process, int *displacement);
    
    /**
     * Gets number of matrix rows that will handle each process.
     * 
     * @param rows_per_process Output array where index is process number and value is number of rows.
     */
    void get_rows_per_process(int *rows_per_process);
    
    /**
     * Calculates a scalar product of each input vector on vector to compare and returns products vector.
     * 
     * @param vectors Float vectors.
     * @return Products vector.
     */
    std::vector<float> scalar_product(std::vector< std::vector<float> > &vectors);
    
public:
    ProcessFlow ();
    
    /**
     * Start process flow.
     * 
     * @param argc Value from main() function.
     * @param argv Value from main() function.
     */
    bool run(int argc, char **argv);
};

#endif	/* MASTER_HPP */

