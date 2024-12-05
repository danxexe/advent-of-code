import argv

pub fn main() {
  do_main()
}

import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/result
import gleam/string

@external(javascript, "./gleeunit_ffi.mjs", "main")
fn do_main() -> Nil {
  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]
  let arguments = argv.load().arguments
  let file_pattern = case arguments {
    [day] -> "**/" <> day <> "_test.{erl,gleam}"
    _ -> "**/*.{erl,gleam}"
  }

  let result =
    find_files(matching: file_pattern, in: "test")
    |> list.map(gleam_to_erlang_module_name)
    |> list.map(dangerously_convert_string_to_atom(_, Utf8))
    |> run_eunit(options)
    |> dynamic.result(dynamic.dynamic, dynamic.dynamic)
    |> result.unwrap(Error(dynamic.from(Nil)))

  let code = case result {
    Ok(_) -> 0
    Error(_) -> 1
  }
  halt(code)
}

@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil

fn gleam_to_erlang_module_name(path: String) -> String {
  path
  |> string.replace(".gleam", "")
  |> string.replace(".erl", "")
  |> string.replace("/", "@")
}

@external(erlang, "gleeunit_ffi", "find_files")
fn find_files(matching matching: String, in in: String) -> List(String)

type Atom

type Encoding {
  Utf8
}

@external(erlang, "erlang", "binary_to_atom")
fn dangerously_convert_string_to_atom(a: String, b: Encoding) -> Atom

type ReportModuleName {
  GleeunitProgress
}

type GleeunitProgressOption {
  Colored(Bool)
}

type EunitOption {
  Verbose
  NoTty
  Report(#(ReportModuleName, List(GleeunitProgressOption)))
}

@external(erlang, "eunit", "test")
fn run_eunit(a: List(Atom), b: List(EunitOption)) -> Dynamic
