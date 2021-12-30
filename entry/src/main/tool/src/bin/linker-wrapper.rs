use std::env;
use std::fs;
use std::process::Command;
use anyhow::{Context, Result, bail};

fn main() -> Result<()> {
    let c_linker = env::var("C_LINKER")
        .with_context(|| format!("Failed to get C_LINKER environment variable. "))?;

    let args = collect_cleaned_args()?;

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

fn collect_cleaned_args() -> Result<Vec<String>> {
    let os = env::consts::OS;
    if os != "windows" && os != "macos" {
        bail!("Unsupported operation system: {}", os);
    }

    let mut args = vec![];
    for arg in env::args().skip(1) {
        if arg != "-llog" {
            args.push(arg);
        }
    }

    // see https://stackoverflow.com/questions/40727748/windows-clang-command-line-too-long
    if os == "windows" && args.len() == 1 && args[0].starts_with("@") {
        let filename = &args[0][1..];
        // 用下面一行来确定 response file 的格式是每行一个参数。直接将-llog行删除掉即可。
        // fs::write("liker-args.txt", &contents)?;
        let contents = fs::read_to_string(filename)?
            .replace("-llog\n", "");
        fs::write(filename, &contents)?;
    }

    return Ok(args)
}
