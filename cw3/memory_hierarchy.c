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
int index_num;
int tag;
int temp;

struct cache_sucks
{
	int *cache_store;
	int index_total;
	int index_size;
	int curr_pushed;
	int empty_block;

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
        
		cache.index_total      = cache_size / block_size;
		cache.index_size       = (int) log2((double) cache.index_total);

        switch(cache_type)
		{
        	case CACHE_TYPE_DIRECT: // direct mapped
			
				
   				cache.cache_store = malloc(cache.index_total *block_size*4*sizeof(uint32_t));

   				for (int i = 0; i < cache.index_total; i++)
				{
         			*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) + 0*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) + 4*1*sizeof(uint32_t)) = -1;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) + 4*2*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) + 4*3*sizeof(uint32_t)) = 0;
				}	

				temp = 32 - cache.index_size - offset_size;

				memory_stats_init(arch_state_ptr, temp); 
				break;

        	case CACHE_TYPE_FULLY_ASSOC: // fully associative

				cache.cache_store = malloc(4*cache.index_total *block_size*sizeof(uint32_t)); 
				cache.curr_pushed = 0;

   				for (int i = 0; i < cache.index_total; i++)
				{
         			*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4*0*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 1*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 2*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 3*sizeof(uint32_t)) = 0;
				}	
				cache.empty_block = 0;

				temp = 32 - offset_size;

				memory_stats_init(arch_state_ptr, temp); 
				break;
        	case CACHE_TYPE_2_WAY: // 2-way associative
            	cache.cache_store = malloc(cache.index_total* 4*block_size*sizeof(uint32_t));

   				for (int i = 0; i < cache.index_total; i++)
				{
         			*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 0*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 1*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 2*sizeof(uint32_t)) = 0;
					*(cache.cache_store +4* i*block_parts*sizeof(uint32_t) +4* 3*sizeof(uint32_t)) = 0;
				}	
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
				
					index_num = get_piece_of_a_word(address, offset_size, cache.index_size); 
					tag 	  = get_piece_of_a_word(address,(offset_size + cache.index_size), (32-offset_size-cache.index_size));
					int cache_tag = *(cache.cache_store +4* index_num*block_parts*sizeof(uint32_t) +4* 1*sizeof(uint32_t));
					
					// This part is some temp values that's already stored in cache
					// we just make them look horter
					if (cache_tag == tag) 
					{
						arch_state.mem_stats.lw_cache_hits++;
					}
					else
					{
						*(cache.cache_store +4* index_num * block_parts*sizeof(uint32_t))     = 1; //valid
						*(cache.cache_store +4* index_num * block_parts*sizeof(uint32_t) + 4*1*sizeof(uint32_t)) = tag; //tag
						*(cache.cache_store +4* index_num * block_parts*sizeof(uint32_t) + 4*2*sizeof(uint32_t)) = (int) arch_state.memory[address / 4];//data
					}

 				//	if ((int) *(cache.cache_store +4* index_num * block_parts*sizeof(uint32_t) +4*2*sizeof(uint32_t)) == (int) arch_state.memory[address/4],(int) arch_state.memory[address / 4]);
				//	    printf("cache: %u, mem: %u\n", (int) *(cache.cache_store +4* index_num * block_parts*sizeof(uint32_t) +4*2*sizeof(uint32_t)),(int) arch_state.memory[address / 4]);
					return (int) arch_state.memory[address / 4];
					break;







        	case CACHE_TYPE_FULLY_ASSOC: // fully associative
				
				;
				int max_lru_index;
				int max_lru = -1;

				tag  = get_piece_of_a_word(address,offset_size, (32-offset_size));

				for (int i = 0;i < cache.index_size;i++)
				{
					if (*(cache.cache_store +4*i*block_parts*sizeof(uint32_t) +4*1*sizeof(uint32_t)) == tag
							&& *(cache.cache_store +4*i*block_parts*sizeof(uint32_t))==1)
					{
						//if a hit:
						*(cache.cache_store + 4*i*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = 1;
						
						arch_state.mem_stats.lw_cache_hits++;
						cache.curr_pushed = i;	
						for (int j = 0;j < cache.index_total;j++)
						{
						
							int aa = *(cache.cache_store + 4*j*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t));
							printf("aa: %d\n", aa);
							if (j!=i && aa++ != 0)
								*(cache.cache_store + 4*j*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = aa;
							
						}

						printf("i: %d\n", i);
						printf("-----------------------------------\n");

						return (int) arch_state.memory[address / 4];

					}
				}




				//not a hit
				if (cache.empty_block < cache.index_total)
				{
					*(cache.cache_store +4*cache.empty_block*block_parts*sizeof(uint32_t))     = 1;
					*(cache.cache_store +4*cache.empty_block*block_parts*sizeof(uint32_t) +4* 1*sizeof(uint32_t)) = tag;
					*(cache.cache_store +4*cache.empty_block*block_parts*sizeof(uint32_t) +4* 2*sizeof(uint32_t)) = (int) arch_state.memory[address / 4];
					*(cache.cache_store + 4*cache.empty_block*block_parts*sizeof(uint32_t) +4* 3*sizeof(uint32_t))= 1;

					cache.curr_pushed      = cache.empty_block;
					for (int j = 0;j < cache.index_total;j++)
					{

						int aa =  *(cache.cache_store+4*j*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t));
						
						printf("aa: %d\n", aa);

						if (j != cache.empty_block && aa++ != 0)
							*(cache.cache_store+4*j*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = aa;
						
					}
					printf("-----------------------\n");
					cache.empty_block++;
					return (int) arch_state.memory[address / 4];

				}
				else
				{
					
					for (int i = 0;i < cache.index_total;i++)
					{
						int taskdjfkdjfkd = *(cache.cache_store + 4*i*block_parts*sizeof(uint32_t) +4* 3*sizeof(uint32_t));				
						if (taskdjfkdjfkd > max_lru)
						{
							max_lru = taskdjfkdjfkd;
							max_lru_index = i;
						}
					//	printf("taskdjfkdjfkd %d %d\n",i, taskdjfkdjfkd);
					}
					printf("max lru : %d index: %d\n", max_lru, max_lru_index);


					for (int i = 0;i < cache.index_total;i++)
					{
						
						int aa = *(cache.cache_store + 4*i*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t));

				//		printf("aa: %d %d\n",i, aa);
						if (i!=max_lru_index && aa++ != 0)
							*(cache.cache_store + 4*i*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = aa;
					}
					printf("--------------------------\n");
				
					*(cache.cache_store +4* max_lru_index*block_parts*sizeof(uint32_t)) = 1;
					*(cache.cache_store +4* max_lru_index*block_parts*sizeof(uint32_t) +4*1*sizeof(uint32_t)) = tag;
					*(cache.cache_store +4* max_lru_index*block_parts*sizeof(uint32_t) +4*2*sizeof(uint32_t)) = (int) arch_state.memory[address / 4];
					*(cache.cache_store +4* max_lru_index*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = 1;

					cache.curr_pushed = max_lru_index;				
				}
				
				return (int) arch_state.memory[address / 4];

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
				index_num = get_piece_of_a_word(address, offset_size, cache.index_size);
				tag = get_piece_of_a_word(address,offset_size+cache.index_size, (32-offset_size-cache.index_size));;
			//	get_piece_of_a_word(address, INDEX_SIZE + OFFSET_SIZE, TAG_SIZE);

				int cache_tag = *(cache.cache_store +4* index_num*block_parts*sizeof(uint32_t)+ 4*1*sizeof(uint32_t));
			//	printf("(sw)index: %d tag:%d, cache_tag: %d\n", index_num, tag, cache_tag);	
				

				if (cache_tag == tag) 
				{

					arch_state.mem_stats.sw_cache_hits++;

					*(cache.cache_store+4* index_num*block_parts*sizeof(uint32_t) +4*2*sizeof(uint32_t)) = (uint32_t) write_data;
					//arch_state.memory[address / 4] = *(cache.cache_store+ index_num*block_parts + 2);

					arch_state.memory[address / 4] = *(cache.cache_store+4* index_num*block_parts*sizeof(uint32_t) +4* 2*sizeof(uint32_t));
				}
				else
				{
					arch_state.memory[address / 4] = (uint32_t) write_data;
				}
				break;

       		case CACHE_TYPE_FULLY_ASSOC: // fully associative
				
				
				tag  = get_piece_of_a_word(address,offset_size, (32-offset_size));
				for (int i = 0;i < cache.index_total;i++)
				{
					if (*(cache.cache_store +4*i*block_parts*sizeof(uint32_t) +4*1*sizeof(uint32_t)) == tag)
					{
						*(cache.cache_store+4*i*block_parts*sizeof(uint32_t) +4*2*sizeof(uint32_t)) = (uint32_t) write_data;
						*(cache.cache_store+4*i*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = 1;

						arch_state.mem_stats.sw_cache_hits++;
						cache.curr_pushed = i;
						arch_state.memory[address / 4] = (uint32_t) write_data;
						break;

						for (int j = 0;j < cache.index_total;j++)
						{

							int aa =  *(cache.cache_store+4*j*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t));
							
						//	printf("aa: %d\n", aa);
							if (j != cache.curr_pushed && aa++ != 0)
								*(cache.cache_store+4*j*block_parts*sizeof(uint32_t) +4*3*sizeof(uint32_t)) = aa;
							
						}

					}	
						

				}

				arch_state.memory[address / 4] = (uint32_t) write_data;

            	break;
        	case CACHE_TYPE_2_WAY: // 2-way associative
            	break;
		}
	}
}
