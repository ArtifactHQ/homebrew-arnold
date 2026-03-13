class Arnold < Formula
  desc "AI-orchestrated software development pipeline"
  homepage "https://github.com/ArtifactHQ/Arnold"
  url "https://github.com/ArtifactHQ/Arnold.git", branch: "master"
  version "0.2.1"
  license "MIT"

  depends_on "ruby"
  depends_on "sqlite3"

  def install
    ruby = Formula["ruby"].opt_bin/"ruby"
    gem = Formula["ruby"].opt_bin/"gem"

    ENV["GEM_HOME"] = libexec/"gems"
    ENV["GEM_PATH"] = libexec/"gems"

    system gem, "install", "bundler", "--no-document",
           "--install-dir", libexec/"gems"

    bundle = libexec/"gems/bin/bundle"
    system bundle, "config", "set", "--local", "path", libexec/"gems"
    system bundle, "config", "set", "--local", "without", "development:test"
    system bundle, "config", "set", "--local", "jobs", "4"
    system bundle, "install"

    # Copy the entire project into libexec, preserving directory structure.
    # This includes app/, config/, db/, exe/, lib/, library/ (YAML personas
    # and recipes), plus top-level files needed by Bundler and the gemspec.
    libexec.install Dir["app", "config", "db", "exe", "lib", "library",
                        "Gemfile", "Gemfile.lock", "arnold_pipeline.gemspec",
                        "Rakefile", "MIT-LICENSE", ".bundle"]

    chmod 0755, libexec/"exe/arnold"

    (bin/"arnold").write <<~SH
      #!/bin/bash
      export BUNDLE_GEMFILE="#{libexec}/Gemfile"
      export GEM_HOME="#{libexec}/gems"
      export GEM_PATH="#{libexec}/gems"
      export RUBYLIB="#{libexec}/lib"
      export PATH="#{libexec}/gems/bin:$PATH"
      exec "#{ruby}" -rbundler/setup "#{libexec}/exe/arnold" "$@"
    SH
    chmod 0755, bin/"arnold"
  end

  # MCP server over stdio, managed by brew services.
  # Clients (e.g. Claude Desktop) connect via stdin/stdout.
  service do
    run [opt_bin/"arnold", "mcp"]
    keep_alive true
    working_dir var/"arnold"
    log_path var/"log/arnold.log"
    error_log_path var/"log/arnold.log"
  end

  def post_install
    (var/"arnold").mkpath
    (var/"log").mkpath
  end

  def caveats
    <<~EOS
      Arnold Pipeline stores its data at:
        ~/.arnold_pipeline/pipeline.sqlite3

      Configuration file:
        ~/.arnold_pipeline/config.yml

      To start the MCP server as a background service:
        brew services start arnold

      To verify your installation:
        arnold version
        arnold doctor
    EOS
  end

  test do
    assert_match "arnold_pipeline #{version}", shell_output("#{bin}/arnold version")
  end
end
