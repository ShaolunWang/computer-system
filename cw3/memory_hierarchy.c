/*************************************************************************************|
|   1. YOU ARE NOT ALLOWED TO SHARE/PUBLISH YOUR CODE (e.g., post on piazza or online)|
|   2. Fill memory_hierarchy.c                                                        |
|   3. Do not use any other .c files neither alter mipssim.h or parser.h              |
|   4. Do not include any other library files                                         |
|*************************************************************************************/

#include "mipssim.h"
// cache_size = the data size stored in cache
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
int block_size  = 16; //without thouse metadata, tag valid etc
int block_parts = 4; // tag, valid, data, last pushed
int offset_size = 4;
int shifted_address; 


struct cache_sucks
{
	int *cache_store;
	int LRU;
	int index_total;
	int index_size;
	int last_pushed; // index for the last one pushed
	int next_pop; // index for the next one to pop
} cache;

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
        
		memory_stats_init(arch_state_ptr, cache_size); 
		cache.index_total      = cache_size / block_size;
		cache.index_size       = (int) log2((double) cache.index_total);



        
        switch(cache_type)
		{
        	case CACHE_TYPE_DIRECT: // direct mapped
			
				
   				cache.cache_store = (int *) malloc(cache.index_total * block_parts * sizeof(uint32_t)); 
				cache.last_pushed = -1;

   				for (int i = 0; i < cache.index_total; i++)
				{
         			*(cache.cache_store + i*block_parts + 0) = 0;
					*(cache.cache_store + i*block_parts + 1) = -1;
					*(cache.cache_store + i*block_parts + 2) = 0;
					*(cache.cache_store + i*block_parts + 3) = 0;
				}	
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
				// 1 address to tag and index and offset	
				;
				
				int index_num = get_piece_of_a_word(address, offset_size, cache.index_size); 
				int tag 	  = get_piece_of_a_word(address,(offset_size + cache.index_size), (32-offset_size-cache.index_size));
				int cache_tag = *(cache.cache_store + index_num*block_parts + 1);
				
				//get_piece_of_a_word(address, INDEX_SIZE + OFFSET_SIZE, TAG_SIZE);
				
			//	printf("(lw)address: %d, index: %d, tag:%d, cache_tag: %d\n", address,index_num, tag,cache_tag);	
				// This part is some temp values that's already stored in cache
				// we just make them look horter
				if (cache_tag == tag) 
				{
					arch_state.mem_stats.lw_cache_hits++;
					printf("hits\n");
				}
				else
				{
					*(cache.cache_store + index_num * block_parts)     = 1; //valid
					*(cache.cache_store + index_num * block_parts + 1) = tag; //tag
					*(cache.cache_store + index_num * block_parts + 2) = (int) arch_state.memory[address / 4];//data
				}
								
				//return *(cache.cache_store + index_num*block_parts + 2);
				return (int) arch_state.memory[address / 4];
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
    	       	
				;	
				int index_num = get_piece_of_a_word(address, offset_size, cache.index_size); 
				int tag = get_piece_of_a_word(address,offset_size+cache.index_size, (32-offset_size-cache.index_size));;
			//	get_piece_of_a_word(address, INDEX_SIZE + OFFSET_SIZE, TAG_SIZE);

				int cache_tag = *(cache.cache_store + index_num*block_parts + 1);
			//	printf("(sw)index: %d tag:%d, cache_tag: %d\n", index_num, tag, cache_tag);	
				// This part is some temp values that's already stored in cache
				// we just make them look horter

				if (cache_tag == tag) 
				{

					arch_state.mem_stats.sw_cache_hits++;

					*(cache.cache_store+ index_num*block_parts + 2) = (uint32_t) write_data;
					//arch_state.memory[address / 4] = *(cache.cache_store+ index_num*block_parts + 2);

					arch_state.memory[address / 4] = (uint32_t) write_data;
				}
				else
				{
					arch_state.memory[address / 4] = (uint32_t) write_data;
				}
								
				break;

       		case CACHE_TYPE_FULLY_ASSOC: // fully associative
            	break;
        	case CACHE_TYPE_2_WAY: // 2-way associative
            	break;
		}
	}
}
