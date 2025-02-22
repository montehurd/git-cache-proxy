Provides a transparent git caching proxy that:

1. Is easy to use - simply slightly modify the `.git` url being cloned
2. Intercepts git clone/fetch requests via git's HTTP protocol
3. On first request for a repository:
   - Creates a `--bare` clone of the upstream repository
   - Stores it in a Docker volume (`repo-cache`)
   - Serves the clone request from this local copy
4. On subsequent requests:
   - First updates the cached bare repo with `git fetch`
   - Then serves the request from the local cache
   - Results in significantly faster clones

The proxy is transparent to git clients - they interact with it just like any git HTTP server

The caching happens automatically without any special configuration needed on the client side aside from the adjusted url

# Try it

Start it:

`./start`

Then, instead of cloning the repo's url directly like this:

`git clone http://gerrit.wikimedia.org/r/mediawiki/skins/Vector.git`

Do this:

`git clone http://localhost:8765/gerrit.wikimedia.org/r/mediawiki/skins/Vector.git`

^ Note the url starts with `http://localhost:8765`, followed by the repo url

# Benefits
- Faster repeat clones of large repositories
- Reduces load on upstream git servers
- Works with any git HTTP URL
- Maintains a single source of truth via the bare repository
- Preserves all git functionality (branches, tags, etc)
- Implemented using a super lightweight Alpine image
- A per-repo locking mechanism ensures concurrent clone requests for the same repo wait for any in-progress cache clone/fetch to complete before being served from the cache

# Scripts

* `./print-cache` 

  Displays the current contents of the cache using `tree`, showing all cached repositories and their internal structure

* `./reset-cache`

  Clears repositories from the cache. When run without arguments, removes all cached repositories. Can also remove a specific repository by passing its URL

  Clear entire cache:

  `./reset-cache`

  Remove specific repo cache:

  `./reset-cache http://example.com/repo.git`

* `./start`

  Brings up the caching proxy:

  - Removes any existing containers and images
  - Starts the service on port 8765 
  - Shows container logs for monitoring

  You can uncomment the last line to debug the `git-cache-handler.sh` script instead

* `./test` 

  Runs integration tests to verify the cache is working correctly:

  - Starts the proxy
  - Performs two clones of the same repository
  - Validates that the second clone is faster than the first
  - Cleans up test repositories and containers

# Notes

While the cache maintains full-depth clones internally, clients can still use options like `--depth` to create shallow clones from the cached repository. This gives you the best of both worlds - the cache has all history available, but clients can choose how much they want to fetch from the cache

# Debugging

After running `./start` you can tail `progress.log`:

`docker compose exec git-cache tail -f /var/log/git-cache/progress.log`