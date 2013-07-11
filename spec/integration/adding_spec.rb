require File.dirname(__FILE__) + '/../integration_helper'

describe "Adding a mirror in a clean repository" do

  before do
    FileUtils.rm_rf(TMP_PATH)
    FileUtils.mkdir_p(TMP_PATH)
  end

  describe "from a git repository" do
    before do
      @shiny = create_git_repo_from_fixture("shiny")
      @skit1 = create_git_repo_from_fixture("skit1")
    end

    it "should add the files and commit" do
      in_dir(@shiny) do
        if VER_WIN32
          `ruby #{BRAID_BIN} add #{@skit1}`
        else
          `#{BRAID_BIN} add #{@skit1}`
        end
        end

      file_name = "skit1/layouts/layout.liquid"
      output    = `diff -U 3 #{File.join(FIXTURE_PATH, file_name)} #{File.join(TMP_PATH, "shiny", file_name)}`
      $?.should be_success

      output = `git log --pretty=oneline`.split("\n")
      output.length.should == 2
      output[0].should =~ /Braid: Add mirror 'skit1' at '[0-9a-f]{7}'/
    end

    it "should create .braids and add the mirror to it" do
      in_dir(@shiny) do
         if VER_WIN32
          `ruby #{BRAID_BIN} add #{@skit1}`
        else
          `#{BRAID_BIN} add #{@skit1}`
        end
      end

      braids = YAML::load_file("#{@shiny}/.braids")
      braids["skit1"]["squashed"].should == true
      braids["skit1"]["url"].should == @skit1
      braids["skit1"]["revision"].should_not be_nil
      braids["skit1"]["branch"].should == "master"
      braids["skit1"]["remote"].should == "master/braid/skit1"
    end
  end
end
