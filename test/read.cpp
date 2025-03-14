#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <rados/librados.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>
#include <algorithm>
#include <random>
#include <iostream>
#include <chrono>

#define NUM_THREADS 128
#define MAX_FILES 1000

int num_files;
uint64_t filesize;
int seed = 0;
int times = 1;
char *buffer;

void print_time()
{

    // Get the current time
    time_t now;
    time(&now); // Obtain the current time

    // Convert to local time format
    struct tm *local = localtime(&now);

    // Print the current time
    printf("Current local time: %s", asctime(local));
}

void *read_file(void *arg)
{
    int err;
    rados_t cluster;
    err = rados_create(&cluster, NULL);
    if (err < 0)
    {
        fprintf(stderr, "%s: cannot create a cluster handle: %s\n", __func__, strerror(-err));
        exit(1);
    }

    err = rados_conf_read_file(cluster, "/etc/ceph/ceph.conf");
    if (err < 0)
    {
        fprintf(stderr, "%s: cannot read config file: %s\n", __func__, strerror(-err));
        exit(1);
    }

    err = rados_connect(cluster);
    if (err < 0)
    {
        fprintf(stderr, "%s: cannot connect to cluster: %s\n", __func__, strerror(-err));
        exit(1);
    }

    rados_ioctx_t io;
    char poolname[] = "default.rgw.buckets.data";
    err = rados_ioctx_create(cluster, poolname, &io);
    if (err < 0)
    {
        fprintf(stderr, "%s: cannot open rados pool %s: %s\n", __func__, poolname, strerror(-err));
        rados_shutdown(cluster);
        exit(1);
    }
    FILE *file;
    // long filesize;
    buffer = (char *)malloc(filesize + 1); // +1 for the null terminator

    if (buffer == NULL)
    {
        perror("Memory error");
        return NULL;
    }
    // rados_ioctx_t io = *(rados_ioctx_t *)arg;

    rados_completion_t comp[MAX_FILES];
    for (int i = 0; i < num_files; i++)
    {
        err = rados_aio_create_completion(NULL, NULL, NULL, &comp[i]);
        if (err < 0)
        {
            fprintf(stderr, "%s: Could not create aio completion: %s\n", __func__, strerror(-err));
            return NULL;
        }
    }

    int ord[MAX_FILES];
    uint64_t thread_id = (uint64_t)arg;
    for (int i = 0; i < num_files; i++)
        ord[i] = i;
    std::mt19937 rng(thread_id + seed * NUM_THREADS);

    // Shuffle the list using the random number generator
    std::shuffle(ord, ord + num_files, rng);

    // clock_t start, end;
    // print_time();
    sleep(2);
    auto start = std::chrono::high_resolution_clock::now();

    // printf("Thread start at: %f\n", (double)(start) / CLOCKS_PER_SEC);
    /* Next, read data using rados_aio_read. */
    for (int i = 0; i < num_files; i++)
    {
        char filename[20];
        sprintf(filename, "object%d", ord[i]);
        err = rados_aio_read(io, filename, comp[ord[i]], buffer, filesize, 0);
        if (err < 0)
        {
            fprintf(stderr, "%s: Cannot read object. %s\n", __func__, strerror(-err));
            return NULL;
        }
    }

    /* Wait for the operation to complete */
    for (int i = 0; i < num_files; i++)
    {
        rados_aio_wait_for_complete(comp[ord[i]]);
        rados_aio_release(comp[ord[i]]);
    }

    // for (int j = 0; j < times; j++)
    //     for (int i = 0; i < num_files; i++)
    //     {
    //         char filename[20];
    //         sprintf(filename, "object%d", ord[i]);
    //         int err = rados_read(io, filename, buffer, filesize, 0);
    //         if (err < 0)
    //         {
    //             fprintf(stderr, "Cannot read object: %s\n", strerror(-err));
    //             return NULL;
    //         }
    //     }
    auto stop = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::seconds>(stop - start);

    std::cout << duration.count() << std::endl; // Time in seconds

    rados_ioctx_destroy(io);
    rados_shutdown(cluster);
    return NULL;
}

int main(int argc, char **argv)
{

    if (argc != 5)
    {
        printf("Usage: %s <num_files> <filesize in Mbs> <num_threads> <seed>\n", __func__);
        return 1;
    }

    num_files = atoi(argv[1]);
    filesize = (uint64_t)atoi(argv[2]) * 1024 * 1024; // File size in bytes
    int numCores = atoi(argv[3]);
    seed = atoi(argv[4]);

    // // Open the file in binary read mode
    // file = fopen("file.txt", "rb");
    // if (file == NULL)
    // {
    //     perror("Error opening file");
    //     return 1;
    // }

    // // Seek to the end of the file to determine its size
    // fseek(file, 0, SEEK_END);
    // filesize = ftell(file);
    // rewind(file); // Rewind the file pointer to the beginning of the file

    // Allocate memory for the buffer

    // long numCores = sysconf(_SC_NPROCESSORS_ONLN) / 2;
    if (numCores < 0)
    {
        perror("Error getting number of cores");
        return 1;
    }
    pthread_t thread[NUM_THREADS];
    for (long t = 0; t < numCores; t++)
        pthread_create(&thread[t], NULL, &read_file, (void *)(uint64_t)t);

    for (long t = 0; t < numCores; t++)
        pthread_join(thread[t], NULL);
}