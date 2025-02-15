Provides a transparent git caching proxy that:

1. Is easy to use - simply slightly modify the `.git` url being cloned
2. Intercepts git clone/fetch requests via HTTP
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

# Notes

While the cache maintains full-depth clones internally, clients can still use options like `--depth` to create shallow clones from the cached repository. This gives you the best of both worlds - the cache has all history available, but clients can choose how much they want to fetch from the cache

# Debugging

After running `./start` you can tail progress.log:

`docker compose exec git-cache tail -f /var/log/git-cache/progress.log`