# The KEY=value file holding the integration tests' Xero credentials:
# .xero.env in the repo root, or the path in XERO_ENV_FILE.
# Variables already set in the environment win over the file, except for the
# tokens XeroToken rotates, which it reads from the file.
module XeroEnv
  LINE = /^\s*(?:export\s+)?([A-Z_]+)=(.*)$/

  module_function

  def path
    File.expand_path(ENV["XERO_ENV_FILE"] || ".xero.env", File.expand_path("../..", __dir__))
  end

  def file_values
    return {} unless File.exist?(path)

    File.read(path).scan(LINE).to_h { |k, v| [k, v.strip.gsub(/\A["']|["']\z/, "")] }
  end

  def values
    file_values.merge(ENV.to_h.reject { |_, v| v.empty? })
  end

  # For a symlink, the file it points to: renaming over the link would replace it with a regular file.
  def write_path
    File.symlink?(path) ? File.realpath(path) : path
  end

  def load
    values.each { |key, value| ENV[key] = value }
  end

  # Sets every KEY= line in the file (or appends one), keeping the rest, and sets
  # ENV too so child processes such as the test run see the new values.
  def write(pairs)
    text = File.exist?(path) ? File.read(path) : ""
    pairs.each { |key, value| text = set_line(text, key, value) }
    replace_file(text)
    pairs.each { |key, value| ENV[key] = value.to_s }
  end

  # Replaces the value on every KEY= line, with or without `export`, or appends KEY=value.
  def set_line(text, key, value)
    line = /^(\s*(?:export\s+)?#{key}=).*$/
    return text.gsub(line) { "#{Regexp.last_match(1)}#{value}" } if text.match?(line)

    text += "\n" unless text.empty? || text.end_with?("\n")
    "#{text}#{key}=#{value}\n"
  end

  # Writes a temp file and renames it over write_path, so a failed write leaves the old file.
  def replace_file(text)
    tmp = "#{write_path}.#{Process.pid}.tmp"
    File.open(tmp, File::WRONLY | File::CREAT | File::TRUNC, 0o600) { |f| f.write(text) }
    File.rename(tmp, write_path)
  ensure
    File.unlink(tmp) if tmp && File.exist?(tmp)
  end
end
