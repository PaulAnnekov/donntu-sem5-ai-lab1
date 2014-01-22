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
        matrix_size;
    float random_from=-1000.0,
          random_to=1000.0;
    std::vector< std::vector<float> > matrix;
    
    /**
     * Parses input parameters and returns data to operate.
     * 
     * @param arg_size Number of rows/columns in matrix.
     */
    std::vector< std::vector<float> > parse_input(const char* arg_size);
    
    /**
     * Prepares matrix for send to processes.
     * 
     * @param matrix Input matrix.
     * @return Vector where on rows located on odd places and columns are on even places.
     */
    std::vector<float> matrix_prepare(std::vector< std::vector<float> > const &matrix);
    
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
     * @param rows_per_process Output array where index is process number and value is number of rows.
     * @param displacement Output array where index is process number and value is data offset.
     */
    void get_displace(int *rows_per_process, int *displacement);
    
    /**
     * Calculates a scalar product of corresponding rows and columns.
     * 
     * @param vectors Float vectors. Odd places - rows, even places - columns.
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

