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