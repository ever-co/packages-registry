# Ever Packages Registry (Proxy)

Private npm registry proxy powered by [Verdaccio](https://verdaccio.org), deployed on [Railway](https://railway.app).

**Registry URL**: [https://packages.ever.co](https://packages.ever.co) (private access only — authentication required)

All requests are authenticated — only users with a valid auth token can install or publish packages. Public (unauthenticated) access is disabled by default.

Upstream packages are proxied and cached from the official [npmjs](https://registry.npmjs.org/) registry.

## Deployment

1. Connect this repo to a new Railway service
2. Add a **volume** mounted at `/verdaccio/storage`
3. Deploy — Railway auto-builds the Dockerfile

> Railway assigns `$PORT` automatically. The entrypoint handles it.

### Railway Environment Variables

Add the following variables in **Railway → Service → Variables**:

| Variable            | Value                | Description               |
| ------------------- | -------------------- | ------------------------- |
| `LISTEN_PORT`       | `4873`               | Verdaccio listen port     |
| `PORT`              | `4873`               | Railway required port     |
| `VERDACCIO_PORT`    | `${{registry.PORT}}` | Railway service reference |
| `VERDACCIO_STORAGE` | `/verdaccio/storage` | Persistent storage path   |

## First-Time Setup

After the first deploy, **registration is open** so you can create your admin user:

```bash
npm adduser --registry https://<your-railway-url>
```

This prompts for a username, password, and email.

### Lock Registration

Once your user is created, **disable self-registration** to prevent unauthorized access:

1. Edit `config.yaml` — change `max_users` from `1000` to `-1`:

```yaml
auth:
  htpasswd:
    file: /verdaccio/storage/htpasswd
    max_users: -1
```

2. Commit and push — Railway redeploys automatically
3. Registration is now locked. Only existing users can authenticate.

## Cloudflare Configuration

If serving behind Cloudflare (e.g. `packages.ever.co`), you must disable features that interfere with Verdaccio's web UI:

1. Go to your domain in the **Cloudflare Dashboard**
2. Navigate to **Speed** → **Optimization** → **Content Optimization**
3. **Disable Rocket Loader** — it rewrites `<script>` tags and breaks Verdaccio's SPA
4. Optionally, create a **Page Rule** for `packages.ever.co/*`:
   - Rocket Loader: **Off**
   - Cache Level: **Bypass** (let Verdaccio handle its own caching)

> Without these changes, the web UI will load blank with 404 errors on static assets (`/-/static/vendors.*.js`).

## Client Configuration

### Local Development

Add the registry and auth token to your `~/.npmrc`:

```
registry=https://packages.ever.co/
//packages.ever.co/:_authToken=<your-token>
```

### CI / GitHub Actions

Store the auth token as a GitHub Secret (`VERDACCIO_TOKEN`), then configure in workflows:

```yaml
- name: Configure npm registry
  run: |
    echo "//packages.ever.co/:_authToken=${{ secrets.VERDACCIO_TOKEN }}" >> ~/.npmrc
    echo "registry=https://packages.ever.co/" >> ~/.npmrc
```

### Yarn

```bash
yarn config set registry https://packages.ever.co/
```

## Configuration

All Verdaccio settings are managed through [`config.yaml`](config.yaml). Changes take effect on the next deploy.

| Setting                           | Description                                                           |
| --------------------------------- | --------------------------------------------------------------------- |
| `auth.htpasswd.max_users`         | Set to `-1` to disable registration, or a positive number to allow it |
| `packages.**.access`              | `$authenticated` requires login, `$all` allows anonymous access       |
| `uplinks.npmjs.url`               | Upstream registry to proxy (default: npmjs)                           |
| `security.api.jwt.sign.expiresIn` | Token expiration (default: 60 days)                                   |

## Architecture

```
Client (yarn/npm) → Cloudflare → Ever Registry (Verdaccio) → npmjs (upstream)
                                        ↓
                                 Railway Volume
                                 /verdaccio/storage/
                                 ├── data/        (cached packages)
                                 └── htpasswd     (user credentials)
```

## License

This project is licensed under the [MIT](LICENSE).

## Contact

- **Website**: [https://ever.co](https://ever.co)
- **Email**: [ever@ever.co](mailto:ever@ever.co)
