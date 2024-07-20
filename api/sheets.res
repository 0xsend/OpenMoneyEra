exception InvalidApiKey({message: string})
exception InvalidId({message: string})
exception InvalidData({message: string})

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

  let json = switch await fetch(
    url,
    {
      method: #GET,
      headers,
    },
  ) {
  | exception exn => raise(exn)
  | res => await res->Response.json->catch(e => raise(e))
  }
  switch json->Types.Sheets.data_decode {
  | Error(_) => raise(InvalidData({message: "Shape of data is invalid"}))
  | Ok({values}) =>
    open Types
    values
    ->Array.filterMap(v =>
      switch v {
      | v if v->Array.length < 3 => None
      | _ =>
        {
          tweetId: ?v[0],
          sendTag: ?v[1],
          tweet: ?v[2],
          name: ?v[3],
          imageUrl: ?v[4],
        }->Some
      }
    )
    ->Array.toReversed
  }
}
