/*************************************************************************************|
|   1. YOU ARE NOT ALLOWED TO SHARE/PUBLISH YOUR CODE (e.g., post on piazza or online)|
|   2. Fill memory_hierarchy.c                                                        |
|   3. Do not use any other .c files neither alter mipssim.h or parser.h              |
|   4. Do not include any other library files                                         |
|*************************************************************************************/

#include "mipssim.h"

/*
*	Fixed parameters:
*	1. Addresses are 32-bits
*	2. Memory is byte addressable
*	3. Cache block size is 16 bytes
*	4. Cache holds both instructions and data (this is called a unified cache)
*	5. Cache uses a write-through policy
*	6. Cache uses a write-no-allocate policy; 
*			i.e.: if a store does not find the target block in the cache, 
*				  it does not allocate it.
*	7. LRU replacement policy (when applicable)
*/
uint32_t cache_type = 0;
int **cache;


int get_index(int cache_size)
{
	// helper function to get the index for the cache
	double index;
	int block = cache_size / 16;
	if (block % 2 == 0)
		index =(int) sqrt((double) block);
	else
		index =(int) sqrt((double) block - block % 2) + 1;

	return index;
}

struct block_entry
{
	//fixed
	int block_size = 16;
	int offset = 4;
	//dynamically allocated
	int tag;
	int valid;
	int data = 32;
}
struct cache_entry
{
	int index_size;
	int set;
	struct block blocks;
}

void cache_init(struct cache_entry cache_entries)
{
	cache = malloc(cache_size);
	for (int i = 0;i < cache_entries.index;i++)
	{
		*(cache + i) = malloc(1 + cache_entries.blocks.tag + cache_entries.blocks.data);
	}
}
void memory_state_init(struct architectural_state *arch_state_ptr)
{
    arch_state_ptr->memory = (uint32_t *) malloc(sizeof(uint32_t) * MEMORY_WORD_NUM);
    memset(arch_state_ptr->memory, 0, sizeof(uint32_t) * MEMORY_WORD_NUM);
    if (cache_size == 0)
	{
        // CACHE DISABLED
        memory_stats_init(arch_state_ptr, 0); // WARNING: we initialize for no cache 0
    } 
	else
	{
        
	    //TODO fill # of tag bits for cache 'X' correctly
		memory_stats_init(arch_state_ptr, arch_state_ptr->bits_for_cache_tag); 
        
        switch(cache_type)
		{
        	case CACHE_TYPE_DIRECT: // direct mapped
				cache_init();

            	break;
        	case CACHE_TYPE_FULLY_ASSOC: // fully associative
            	break;
        	case CACHE_TYPE_2_WAY: // 2-way associative
            	break;
        }
    }
}

// returns data on memory[address / 4]
int memory_read(int address)
{
    arch_state.mem_stats.lw_total++;
    check_address_is_word_aligned(address);

    if (cache_size == 0)
	{
        // CACHE DISABLED
        return (int) arch_state.memory[address / 4];
    }

	else 
	{
        // CACHE ENABLED
        
        // @students: your implementation must properly increment: 
		// arch_state_ptr->mem_stats.lw_cache_hits
        
        switch(cache_type) 
		{
        case CACHE_TYPE_DIRECT: // direct mapped
            break;
        case CACHE_TYPE_FULLY_ASSOC: // fully associative
            break;
        case CACHE_TYPE_2_WAY: // 2-way associative
            break;
        }
    }
    return 0;
}

// writes data on memory[address / 4]
void memory_write(int address, int write_data)
{
    arch_state.mem_stats.sw_total++;
    check_address_is_word_aligned(address);

    if (cache_size == 0) 
	{
        // CACHE DISABLED
        arch_state.memory[address / 4] = (uint32_t) write_data;
    } 
	else 
	{
        // CACHE ENABLED
        
        // @students: your implementation must properly increment: arch_state_ptr->mem_stats.sw_cache_hits
        
        switch(cache_type) 
		{
        case CACHE_TYPE_DIRECT: // direct mapped
            break;
        case CACHE_TYPE_FULLY_ASSOC: // fully associative
            break;
        case CACHE_TYPE_2_WAY: // 2-way associative
            break;
        }
    }
}
