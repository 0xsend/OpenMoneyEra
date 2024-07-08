exception InvalidApiKey({message: string})
exception InvalidId({message: string})

@spice
type data = {values: array<(string, string, string)>}

@spice
type status = | @spice.as("INVALID_ARGUMENT") INVALID_ARGUMENT

@spice
type error = {
  code: int,
  message: string,
  status: status,
}

@val @scope(("process", "env"))
external spreadsheetId: option<string> = "SPREADSHEET_ID"
@val @scope(("process", "env"))
external spreasheetName: option<string> = "SPREADSHEET_NAME"
@val @scope(("process", "env"))
external key: option<string> = "GOOGLE_API_KEY"

let api = "https://sheets.googleapis.com/v4"

let googleKey = switch key {
| Some(key) => key
| None => InvalidApiKey({message: "Google API Key is required"})->raise
}

let spreadsheetId = switch spreadsheetId {
| Some(id) => id
| None => InvalidId({message: "Google Sheets ID is required"})->raise
}

let spreasheetName = spreasheetName->Option.getOr("Sheet1")

let getSheetsData = async () => {
  let url = `${api}/spreadsheets/${spreadsheetId}/values/${spreasheetName}`
  let headers = Headers.Init.object({
    "X-goog-api-key": googleKey,
    "Content-Type": "application/json",
  })->Headers.make

  switch await fetch(
    url,
    {
      method: #GET,
      headers,
    },
  ) {
  | exception exn => raise(exn)
  | res => (await res->Response.json)->data_decode
  }
}




