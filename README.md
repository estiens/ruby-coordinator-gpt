This code is an an experimental and sometimes broken state.
The robot can execute shell commands.
Do not run outside of a virtual machine unless you like to take risks.

Finished

* Few basic services (don't want LLM figuring out how to do what they want to do want to provide them a way to do it)
* Workers which can eventually be controlled by a coordinator
* Postgres vector database for running a database locally
* Call gpt-3/4
* Wrote me a few research articles and once tried to brute force sudo access

To do

* Coordinator
* Prompt Evaluation
* More thinking about shell access
* More analysis of prompt length tradeoffs prompt language tradeoffs
* Implement better context

Thoughts

- How to evaluate autonomous AI abilities against one another
- Shell commands are flexible but exceedingly dangerous to use anywhere but a virtual machine
- Interesting no auto-gpts from what I've seen have any sense that they can ask themselves a question - will spend 10 rounds trying to research basic ruby syntax that it knows - may be a limitation of the language prompting - seems to go significantly better with adding in a call back to GPT each round that can evaluate it's performance and keep it on track, but still does significantly worse than just querying the language model directly
- So far regex parsing of strings seems to be much more reliable that trying to parse JSON from the response
There seems to be lots of interest in simultaneous threaded workers, but I'm not sure if that makes sense - that introduces all sorts of issues and bottleneck is API response time not compute time, but perhaps in the context of having multiple workers work on the same task that share memory?
- Haven't seen significant advantages yet to embeddings for memories, summaries fed right back seem more useful, but perhaps embeddings for pre-ingested data?
