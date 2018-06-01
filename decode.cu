#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>
 
// CUDA kernel. Each thread takes care of one element of c
__global__ void encode(char *encodedText, char *decodedText)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;
    int startEncoded = id * 101;
    int startDecoded = id * 4;
    int t,finish=startEncoded+100;
    // Make sure we do not go out of bounds
    if (id < 15360)
    {
        for(t=startEncoded;t<finish;t++)
        {
            if(encodedText[t]==',')
            {
                decodedText[startDecoded]=encodedText[t+1];
                startDecoded++;
            }
        }
    }
}
 
int main( int argc, char* argv[] )
{
    struct	timeval	stop,	start;
    int decodedSize=15360*4;
    int encodedSize=15360*101;
    // Size of vectors
    int n = 15360;
    int i,j=0;
 
    // Host input vectors
    char *h_encodedText;
    char *h_decodedText;
    char *h_decodedSerialOnCPU;

 
    // Device input vectors
    char *d_encodedText;
    char *d_decodedText;


    // Size, in bytes, of each vector
    size_t bytesOfEncoded = encodedSize*sizeof(char);
    size_t bytesOfDecoded = decodedSize*sizeof(char);
 
    // Allocate memory for each vector on host
    h_encodedText = (char*)malloc(bytesOfEncoded);
    h_decodedText = (char*)malloc(bytesOfDecoded);
    h_decodedSerialOnCPU = (char*)malloc(bytesOfDecoded);
   
 
    // Allocate memory for each vector on GPU
    cudaMalloc(&d_encodedText, bytesOfEncoded);
    cudaMalloc(&d_decodedText, bytesOfDecoded);
    

    int blockSize, gridSize;
 
    // Number of threads in each thread block
    blockSize = 512;
 
    // Number of thread blocks in grid
    gridSize = (int)ceil((float)n/blockSize);


    /* Open your_file in read-only mode */
    FILE *fp = fopen("encodedfile.txt", "r");

    /* Read the file into the buffer */
    fread(h_encodedText, bytesOfEncoded-1, 1, fp); /* Read 1 chunk of size bytes from fp into buffer */

    /* NULL-terminate the buffer */
    h_encodedText[bytesOfEncoded] = '\0';

    gettimeofday(&start,	NULL);
    for(i=0;i<bytesOfEncoded;i++)
    {
    if(h_encodedText[i]==',')
    {
    h_decodedSerialOnCPU[j++]=h_encodedText[i+1];}
    }
    gettimeofday(&stop,	NULL);
    float	SerialElapsed	=	(stop.tv_sec	- start.tv_sec)	*	1000.0f	+	(stop.tv_usec	- start.tv_usec)	/	1000.0f;
    printf("Code	executed	in	%f	milliseconds.\n",	SerialElapsed);

  
  gettimeofday(&start,	NULL);
    // Copy host vectors to device
    cudaMemcpy( d_encodedText, h_encodedText, bytesOfEncoded, cudaMemcpyHostToDevice);
    //cudaMemcpy( d_decodedText, h_decodedText, bytesOfDecoded, cudaMemcpyHostToDevice);
 
 
    // Execute the kernel
    encode<<<gridSize, blockSize>>>(d_encodedText, d_decodedText);
 
    // Copy array back to host
    cudaMemcpy( h_decodedText, d_decodedText, bytesOfDecoded, cudaMemcpyDeviceToHost );
    gettimeofday(&stop,	NULL);
    float elapsed	=	(stop.tv_sec	- start.tv_sec)	*	1000.0f	+	(stop.tv_usec	- start.tv_usec)	/	1000.0f;
    printf("Code	executed	in	%f	milliseconds.\n",	elapsed);

    printf("SpeedUp	%f	.\n",	SerialElapsed/elapsed);

    //Write decoded text
    FILE *file = fopen("decodedfile.txt", "w");

    int results = fputs(h_decodedText, file);
    if (results == EOF) {
    // Failed to write do error code here.
    }
    fclose(file);
 
    // Release device memory
    cudaFree(d_encodedText);
    cudaFree(d_decodedText);
    
 
    // Release host memory
    free(h_encodedText);
    free(h_decodedText);
    
 
    return 0;
}
