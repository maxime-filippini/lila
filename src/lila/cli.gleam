import argv
import clip.{type Command}
import clip/opt.{type Opt}

pub type CommandLineArgs {
  CommandLineArgs(port: Int)
}

fn port_opt() -> Opt(Int) {
  opt.new("port") |> opt.int |> opt.default(42_069)
}

fn command() -> Command(CommandLineArgs) {
  clip.command({
    use port <- clip.parameter

    CommandLineArgs(port)
  })
  |> clip.opt(port_opt())
}

pub fn parse_args() -> CommandLineArgs {
  let assert Ok(result) =
    command()
    |> clip.run(argv.load().arguments)

  result
}
