To try:

`./start`

Then:

`git clone http://localhost:8765/gerrit.wikimedia.org/r/mediawiki/skins/Vector.git`

This project provides a transparent git caching proxy that:

1. Intercepts git clone/fetch requests via HTTP
2. On first request for a repository:
   - Creates a bare clone of the upstream repository
   - Stores it in a Docker volume (`repo-cache`)
   - Serves the clone request from this local copy
3. On subsequent requests:
   - First updates the cached bare repo with `git fetch`
   - Then serves the request from the local cache
   - Results in significantly faster clones

The proxy is transparent to git clients - they interact with it just like any git HTTP server.

The caching happens automatically without any special configuration needed on the client side.

Benefits:
- Faster repeat clones of large repositories
- Reduces load on upstream git servers
- Works with any git HTTP URL
- Maintains a single source of truth via the bare repository
- Preserves all git functionality (branches, tags, etc)
- Implemented using a super lightweight Alpine image

Note: While the cache maintains full-depth clones internally, clients can still use options like --depth to create shallow clones from the cached repository. This gives you the best of both worlds - the cache has all history available, but clients can choose how much they want to fetch from the cache.