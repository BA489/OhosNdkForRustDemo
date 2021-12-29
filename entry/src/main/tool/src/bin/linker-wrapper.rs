use std::env;
use std::process::Command;
use anyhow::{Context, Result, bail};

fn main() -> Result<()> {
    let c_linker = env::var("C_LINKER")
        .with_context(|| format!("Failed to get C_LINKER environment variable. "))?;

    let mut args = vec![];
    for arg in env::args().skip(1) {
        if arg != "-llog" {
            args.push(arg);
        }
    }

    let mut cmd = Command::new(&c_linker);
    cmd.args(args);

    println!("Execute: {:?}", cmd);
    let output = cmd.output().with_context(|| format!("Failed to execute {:?}", cmd))?;

    if ! output.status.success() {
        let stdout_ = String::from_utf8_lossy(&output.stdout);
        let stderr_ = String::from_utf8_lossy(&output.stderr);
        bail!("Failed to execute {:?}\n{}\nSTDOUT:\n{}\nSTDERR:\n{}",
              cmd, output.status, stdout_, stderr_);
    }
    Ok(())
}

