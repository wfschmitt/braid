require File.dirname(__FILE__) + '/../integration_helper'

describe "Updating a mirror without conflicts" do
if RUBY_PLATFORM =~ /(win|w32)/
  VER_WIN32=true
else
  VER_WIN32=false
end

  before do
    FileUtils.rm_rf(TMP_PATH)
    FileUtils.mkdir_p(TMP_PATH)
  end

  describe "from a git repository" do
    before do
      @shiny = create_git_repo_from_fixture("shiny")
      @skit1 = create_git_repo_from_fixture("skit1")

      in_dir(@shiny) do
          if VER_WIN32
            `ruby #{BRAID_BIN} add #{@skit1}`
          else
            `#{BRAID_BIN} add #{@skit1}`
          end
      end

      update_dir_from_fixture("skit1", "skit1.1")
      in_dir(@skit1) do
        `git add *`
        `git commit -m "change default color"`
      end

      update_dir_from_fixture("skit1", "skit1.2")
      in_dir(@skit1) do
        `git add *`
        `git commit -m "add a happy note"`
      end

    end

    it "should add the files and commit" do
      in_dir(@shiny) do
        if VER_WIN32
          `ruby #{BRAID_BIN} update skit1`
         else
           `#{BRAID_BIN} update skit1`
         end
       end

      file_name = "layouts/layout.liquid"
      output    = `diff -U 3 #{File.join(FIXTURE_PATH, "skit1.2", file_name)} #{File.join(TMP_PATH, "shiny", "skit1", file_name)}`
      $?.should be_success

      output = `git log --pretty=oneline`.split("\n")
      output.length.should == 3
      output[0].should =~ /Braid: Update mirror 'skit1' to '[0-9a-f]{7}'/
    end

  end
end
