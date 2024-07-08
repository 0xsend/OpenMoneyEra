%%raw("import './index.css'")

/*
 * Create a new client
 */
let client = ReactQuery.Provider.createClient()

switch ReactDOM.querySelector("#root") {
| Some(domElement) =>
  ReactDOM.Client.createRoot(domElement)->ReactDOM.Client.Root.render(
    <React.StrictMode>
      <ReactQuery.Provider client>
        <App />
      </ReactQuery.Provider>
    </React.StrictMode>,
  )
| None => ()
}
