## Architecture Decisions

### Local testing first

All the steps to be carried out in the pipeline created were to be first carried out locally
  > reduce financial implaications for free tier limits
  > ensure steps carried out locally can be replicated elsewhere when the pipeline succeeds

### Waterfall like pipeline

Create the pipeline as a single run as a waterfall any blockers upstream will cause the pipeline to fail
 > ensuring all the security gates are passed successful 


 ### Using alpine based images

 The small footprint of the base linux image reduces the attack surface area.

 ### Finding replica open source of the stated complaince gates

Finding open source alternatives of the compliance applications through docker to run 
