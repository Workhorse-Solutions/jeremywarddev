# JavaScript — RailsFoundry

## Stack constraints (read before touching anything)

- **No npm/yarn build step.** Asset compilation is Propshaft + import maps only.
- **Do not suggest** `npm install`, `package.json` dependencies, webpack, esbuild,
  or Vite. Node is installed only for Tailwind compilation — not for JS bundling.
- New JS packages must be pinned via import maps: `bin/importmap pin <package>`
- All Stimulus controllers live in `app/javascript/controllers/` and are
  auto-registered by `eagerLoadControllersFrom` in `controllers/index.js`.

## Adding a Stimulus controller

1. Create `app/javascript/controllers/<name>_controller.js`
2. No further registration needed — eager loading picks it up automatically.

```javascript
// app/javascript/controllers/example_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  static values = { message: String }

  connect() {
    // runs when element enters the DOM
  }
}
```

## Import map

Pins are in `config/importmap.rb`. To add a CDN-hosted package:

```bash
bin/importmap pin package-name
```

Verify the pin was added to `config/importmap.rb` and works before committing.

## Adding a Stimulus controller skill

Follow the `add_stimulus_controller` skill when it exists. Until then, follow
the conventions in existing controllers (`flash_controller.js`,
`drawer_controller.js`, `scroll_spy_controller.js`).
