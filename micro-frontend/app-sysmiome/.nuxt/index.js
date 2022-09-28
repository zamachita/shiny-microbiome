import Vue from 'vue'

import Meta from 'vue-meta'
import ClientOnly from 'vue-client-only'
import NoSsr from 'vue-no-ssr'
import { createRouter } from './router.js'
import NuxtChild from './components/nuxt-child.js'
import NuxtError from './components/nuxt-error.vue'
import Nuxt from './components/nuxt.js'
import App from './App.js'
import { setContext, getLocation, getRouteData, normalizeError } from './utils'

/* Plugins */

import nuxt_plugin_plugin_7015dc62 from 'nuxt_plugin_plugin_7015dc62' // Source: .\\components\\plugin.js (mode: 'all')
import nuxt_plugin_bootstrapvue_67c24698 from 'nuxt_plugin_bootstrapvue_67c24698' // Source: .\\bootstrap-vue.js (mode: 'all')
import nuxt_plugin_pluginclient_068e3c18 from 'nuxt_plugin_pluginclient_068e3c18' // Source: .\\content\\plugin.client.js (mode: 'client')
import nuxt_plugin_pluginserver_6c47ada0 from 'nuxt_plugin_pluginserver_6c47ada0' // Source: .\\content\\plugin.server.js (mode: 'server')
import nuxt_plugin_workbox_0844fb61 from 'nuxt_plugin_workbox_0844fb61' // Source: .\\workbox.js (mode: 'client')
import nuxt_plugin_metaplugin_57f2fee1 from 'nuxt_plugin_metaplugin_57f2fee1' // Source: .\\pwa\\meta.plugin.js (mode: 'all')
import nuxt_plugin_iconplugin_5c9aa455 from 'nuxt_plugin_iconplugin_5c9aa455' // Source: .\\pwa\\icon.plugin.js (mode: 'all')
import nuxt_plugin_axios_d00958f6 from 'nuxt_plugin_axios_d00958f6' // Source: .\\axios.js (mode: 'all')

// Component: <ClientOnly>
Vue.component(ClientOnly.name, ClientOnly)

// TODO: Remove in Nuxt 3: <NoSsr>
Vue.component(NoSsr.name, {
  ...NoSsr,
  render (h, ctx) {
    if (process.client && !NoSsr._warned) {
      NoSsr._warned = true

      console.warn('<no-ssr> has been deprecated and will be removed in Nuxt 3, please use <client-only> instead')
    }
    return NoSsr.render(h, ctx)
  }
})

// Component: <NuxtChild>
Vue.component(NuxtChild.name, NuxtChild)
Vue.component('NChild', NuxtChild)

// Component NuxtLink is imported in server.js or client.js

// Component: <Nuxt>
Vue.component(Nuxt.name, Nuxt)

Object.defineProperty(Vue.prototype, '$nuxt', {
  get() {
    const globalNuxt = this.$root.$options.$nuxt
    if (process.client && !globalNuxt && typeof window !== 'undefined') {
      return window.$nuxt
    }
    return globalNuxt
  },
  configurable: true
})

Vue.use(Meta, {"keyName":"head","attribute":"data-n-head","ssrAttribute":"data-n-head-ssr","tagIDKeyName":"hid"})

const defaultTransition = {"name":"page","mode":"out-in","appear":false,"appearClass":"appear","appearActiveClass":"appear-active","appearToClass":"appear-to"}

async function createApp(ssrContext, config = {}) {
  const router = await createRouter(ssrContext, config)

  // Create Root instance

  // here we inject the router and store to all child components,
  // making them available everywhere as `this.$router` and `this.$store`.
  const app = {
    head: {"title":"app-sysmiome","meta":[{"charset":"utf-8"},{"name":"viewport","content":"width=device-width, initial-scale=1"},{"hid":"description","name":"description","content":""},{"name":"format-detection","content":"telephone=no"},{"hid":"charset","charset":"utf-8"},{"hid":"mobile-web-app-capable","name":"mobile-web-app-capable","content":"yes"},{"hid":"apple-mobile-web-app-title","name":"apple-mobile-web-app-title","content":"app-sysmiome"},{"hid":"og:type","name":"og:type","property":"og:type","content":"website"},{"hid":"og:title","name":"og:title","property":"og:title","content":"app-sysmiome"},{"hid":"og:site_name","name":"og:site_name","property":"og:site_name","content":"app-sysmiome"}],"link":[{"rel":"icon","type":"image\u002Fx-icon","href":"\u002Ffavicon.ico"},{"rel":"stylesheet","href":"\u002Fplugins\u002Ffontawesome-free\u002Fcss\u002Fall.min.css"},{"rel":"stylesheet","href":"https:\u002F\u002Fcode.ionicframework.com\u002Fionicons\u002F2.0.1\u002Fcss\u002Fionicons.min.css"},{"rel":"stylesheet","href":"\u002Fplugins\u002Ftempusdominus-bootstrap-4\u002Fcss\u002Ftempusdominus-bootstrap-4.min.css"},{"rel":"stylesheet","href":"\u002Fplugins\u002Ficheck-bootstrap\u002Ficheck-bootstrap.min.css"},{"rel":"stylesheet","href":"\u002Fplugins\u002Fjqvmap\u002Fjqvmap.min.css"},{"rel":"stylesheet","href":"\u002Fdist\u002Fcss\u002Fadminlte.min.css"},{"rel":"stylesheet","href":"\u002Fplugins\u002FoverlayScrollbars\u002Fcss\u002FOverlayScrollbars.min.css"},{"rel":"stylesheet","href":"\u002Fplugins\u002Fdaterangepicker\u002Fdaterangepicker.css"},{"rel":"stylesheet","href":"\u002Fplugins\u002Fsummernote\u002Fsummernote-bs4.css"},{"rel":"stylesheet","href":"https:\u002F\u002Ffonts.googleapis.com\u002Fcss?family=Source+Sans+Pro:300,400,400i,700"},{"hid":"shortcut-icon","rel":"shortcut icon","href":"\u002F_nuxt\u002Ficons\u002Ficon_64x64.e3e9fb.png"},{"hid":"apple-touch-icon","rel":"apple-touch-icon","href":"\u002F_nuxt\u002Ficons\u002Ficon_512x512.e3e9fb.png","sizes":"512x512"},{"rel":"manifest","href":"\u002F_nuxt\u002Fmanifest.a91041ba.json","hid":"manifest"}],"script":[{"src":"\u002Fplugins\u002Fjquery\u002Fjquery.min.js","body":true},{"src":"\u002Fplugins\u002Fjquery-ui\u002Fjquery-ui.min.js","body":true},{"src":"\u002Fplugins\u002Fbootstrap\u002Fjs\u002Fbootstrap.bundle.min.js","body":true},{"src":"\u002Fplugins\u002Fchart.js\u002FChart.min.js","body":true},{"src":"\u002Fplugins\u002Fsparklines\u002Fsparkline.js","body":true},{"src":"\u002Fplugins\u002Fjqvmap\u002Fjquery.vmap.min.js","body":true},{"src":"\u002Fplugins\u002Fjqvmap\u002Fmaps\u002Fjquery.vmap.usa.js","body":true},{"src":"\u002Fplugins\u002Fjquery-knob\u002Fjquery.knob.min.js","body":true},{"src":"\u002Fplugins\u002Fmoment\u002Fmoment.min.js","body":true},{"src":"\u002Fplugins\u002Fdaterangepicker\u002Fdaterangepicker.js","body":true},{"src":"\u002Fplugins\u002Ftempusdominus-bootstrap-4\u002Fjs\u002Ftempusdominus-bootstrap-4.min.js","body":true},{"src":"\u002Fplugins\u002Fsummernote\u002Fsummernote-bs4.min.js","body":true},{"src":"\u002Fplugins\u002FoverlayScrollbars\u002Fjs\u002Fjquery.overlayScrollbars.min.js","body":true},{"src":"\u002Fdist\u002Fjs\u002Fadminlte.js","body":true}],"bodyAttrs":{"class":"hold-transition sidebar-mini layout-fixed"},"style":[],"htmlAttrs":{"lang":"en"}},

    router,
    nuxt: {
      defaultTransition,
      transitions: [defaultTransition],
      setTransitions (transitions) {
        if (!Array.isArray(transitions)) {
          transitions = [transitions]
        }
        transitions = transitions.map((transition) => {
          if (!transition) {
            transition = defaultTransition
          } else if (typeof transition === 'string') {
            transition = Object.assign({}, defaultTransition, { name: transition })
          } else {
            transition = Object.assign({}, defaultTransition, transition)
          }
          return transition
        })
        this.$options.nuxt.transitions = transitions
        return transitions
      },

      err: null,
      dateErr: null,
      error (err) {
        err = err || null
        app.context._errored = Boolean(err)
        err = err ? normalizeError(err) : null
        let nuxt = app.nuxt // to work with @vue/composition-api, see https://github.com/nuxt/nuxt.js/issues/6517#issuecomment-573280207
        if (this) {
          nuxt = this.nuxt || this.$options.nuxt
        }
        nuxt.dateErr = Date.now()
        nuxt.err = err
        // Used in src/server.js
        if (ssrContext) {
          ssrContext.nuxt.error = err
        }
        return err
      }
    },
    ...App
  }

  const next = ssrContext ? ssrContext.next : location => app.router.push(location)
  // Resolve route
  let route
  if (ssrContext) {
    route = router.resolve(ssrContext.url).route
  } else {
    const path = getLocation(router.options.base, router.options.mode)
    route = router.resolve(path).route
  }

  // Set context to app.context
  await setContext(app, {
    route,
    next,
    error: app.nuxt.error.bind(app),
    payload: ssrContext ? ssrContext.payload : undefined,
    req: ssrContext ? ssrContext.req : undefined,
    res: ssrContext ? ssrContext.res : undefined,
    beforeRenderFns: ssrContext ? ssrContext.beforeRenderFns : undefined,
    ssrContext
  })

  function inject(key, value) {
    if (!key) {
      throw new Error('inject(key, value) has no key provided')
    }
    if (value === undefined) {
      throw new Error(`inject('${key}', value) has no value provided`)
    }

    key = '$' + key
    // Add into app
    app[key] = value
    // Add into context
    if (!app.context[key]) {
      app.context[key] = value
    }

    // Check if plugin not already installed
    const installKey = '__nuxt_' + key + '_installed__'
    if (Vue[installKey]) {
      return
    }
    Vue[installKey] = true
    // Call Vue.use() to install the plugin into vm
    Vue.use(() => {
      if (!Object.prototype.hasOwnProperty.call(Vue.prototype, key)) {
        Object.defineProperty(Vue.prototype, key, {
          get () {
            return this.$root.$options[key]
          }
        })
      }
    })
  }

  // Inject runtime config as $config
  inject('config', config)

  // Add enablePreview(previewData = {}) in context for plugins
  if (process.static && process.client) {
    app.context.enablePreview = function (previewData = {}) {
      app.previewData = Object.assign({}, previewData)
      inject('preview', previewData)
    }
  }
  // Plugin execution

  if (typeof nuxt_plugin_plugin_7015dc62 === 'function') {
    await nuxt_plugin_plugin_7015dc62(app.context, inject)
  }

  if (typeof nuxt_plugin_bootstrapvue_67c24698 === 'function') {
    await nuxt_plugin_bootstrapvue_67c24698(app.context, inject)
  }

  if (process.client && typeof nuxt_plugin_pluginclient_068e3c18 === 'function') {
    await nuxt_plugin_pluginclient_068e3c18(app.context, inject)
  }

  if (process.server && typeof nuxt_plugin_pluginserver_6c47ada0 === 'function') {
    await nuxt_plugin_pluginserver_6c47ada0(app.context, inject)
  }

  if (process.client && typeof nuxt_plugin_workbox_0844fb61 === 'function') {
    await nuxt_plugin_workbox_0844fb61(app.context, inject)
  }

  if (typeof nuxt_plugin_metaplugin_57f2fee1 === 'function') {
    await nuxt_plugin_metaplugin_57f2fee1(app.context, inject)
  }

  if (typeof nuxt_plugin_iconplugin_5c9aa455 === 'function') {
    await nuxt_plugin_iconplugin_5c9aa455(app.context, inject)
  }

  if (typeof nuxt_plugin_axios_d00958f6 === 'function') {
    await nuxt_plugin_axios_d00958f6(app.context, inject)
  }

  // Lock enablePreview in context
  if (process.static && process.client) {
    app.context.enablePreview = function () {
      console.warn('You cannot call enablePreview() outside a plugin.')
    }
  }

  // Wait for async component to be resolved first
  await new Promise((resolve, reject) => {
    // Ignore 404s rather than blindly replacing URL in browser
    if (process.client) {
      const { route } = router.resolve(app.context.route.fullPath)
      if (!route.matched.length) {
        return resolve()
      }
    }
    router.replace(app.context.route.fullPath, resolve, (err) => {
      // https://github.com/vuejs/vue-router/blob/v3.4.3/src/util/errors.js
      if (!err._isRouter) return reject(err)
      if (err.type !== 2 /* NavigationFailureType.redirected */) return resolve()

      // navigated to a different route in router guard
      const unregister = router.afterEach(async (to, from) => {
        if (process.server && ssrContext && ssrContext.url) {
          ssrContext.url = to.fullPath
        }
        app.context.route = await getRouteData(to)
        app.context.params = to.params || {}
        app.context.query = to.query || {}
        unregister()
        resolve()
      })
    })
  })

  return {
    app,
    router
  }
}

export { createApp, NuxtError }
