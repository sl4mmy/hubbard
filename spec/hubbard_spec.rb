require 'spec_helper'
require 'fileutils'

describe "Hubbard" do
  before(:each) do
    reset_file_system
  end

  after(:all) do
    reset_file_system
  end

  it "should pass exitstatus along from SystemCallError" do
    pending "Not sure how to make sure that hubbard is passing back the proper exit codes from SystemCallErrors. Doing so would introduce complexity or add something that shouldn't be callable."
  end

  it "should create project and set project description" do
    hub("kipper", "create-project foo")
    hub("kipper", "set-description foo foo-desc")
    projects = list_projects('kipper')
    projects.should == ["foo"]
  end

  it "should set project description" do
    hub("kipper", "create-project foo")
    hub("kipper", "set-description foo 'Test description contains a space.'")
    project = hub("kipper", "list-projects").split("\n")[0].split
    project_name = project.shift # throw away unused arg.
    visibility = project.shift # throw away unused arg.
    description = project.join(' ')
    description.should == "Test description contains a space."
  end

  it "should set project visibility" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "set-visibility foo private")
    project = hub("kipper", "list-projects").split("\n")[0].split
    project[1].should == "private"
  end

  it "should rename project" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "rename-project foo bar")
    project = hub("kipper", "list-projects").split("\n")[0].split
    project[0].should == "bar"
  end

  it "should not allow multiple projects with same name" do
    create_project("kipper", "foo", "foo-desc")
    lambda { hub("kipper", "create-project foo") }.should raise_error
  end

  it "should delete project" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "delete-project foo")

    projects = hub("kipper", "list-projects").split("\n")
    projects.should == []
  end

  it "should default to public project" do
    create_project("kipper", "foo", "foo-desc")

    # Other users can see...
    projects = list_projects("tiger")
    projects.should == ["foo"]

    # But not delete
    lambda { hub("tiger", "delete-project foo") }.should raise_error
  end

  it "should support private project" do
    hub("kipper", "create-project foo --private")
    hub("kipper", "set-description foo new-desc")

    # Other users can't see
    projects = hub("tiger", "list-projects").split("\n")
    projects.should == []
  end

  it "should create repositories" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "create-repository foo bar")

    repositories = hub("kipper", "list-repositories foo").split("\n")
    repositories.length.should == 1
    name,url = repositories[0].split
    name.should == "bar"
    url.should == "#{ENV['USER']}@#{HUB_HOST}:foo/bar.git"    
  end

  describe "when admin creates a project" do
    before(:each) do
      create_project("admin", "foo", "foo-desc")
    end

    it "should not raise error on missing permissions file for non-admin listing permissions" do
      lambda { hub("kipper", "list-permissions foo") }.should_not raise_error(Errno::ENOENT)
    end

    it "should list project permissions for admin" do
      permissions = hub("admin", "list-permissions foo")
      permissions.should == ""
    end
  end

  def with_test_project
    Dir.mkdir('tmp')
    Dir.chdir('tmp') do
      File.open("README", "w") { |f| f << "Hello, world\n" }
      fail unless system "git init"
      fail unless system "git add README"
      fail unless system "git commit -m 'initial commit'" 
      yield
    end
  end

  it "should allow git push" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
    end
  end

  it "should move repository" do
    create_project("kipper", "foo", "foo-desc")
    create_project("kipper", "new-foo", "foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      hub("kipper", "move-repository foo bar new-foo baz")
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:new-foo/baz.git master")
    end
  end

  it "should allow git push with write permissions" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "add-permission foo tiger write")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("tiger", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
    end
  end

  it "should not allow git push with read permissions" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "add-permission foo tiger read")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      lambda { git("tiger", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master") }.should raise_error
    end
  end

  it "should allow git pull" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      git("kipper", "pull #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
    end
  end

  it "should not allow git pull with no permissions" do
    hub("kipper", "create-project foo --private")
    hub("kipper", "set-description foo foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      lambda { git("tiger", "pull #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master") }.should raise_error
    end
  end

  it "should allow git pull with read permissions" do
    hub("kipper", "create-project foo foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      git("tiger", "pull #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
    end
  end

  it "should fork repository in same project" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      hub("kipper", "fork-repository foo bar foo bar2")
      git("kipper", "pull #{ENV['USER']}@#{HUB_HOST}:foo/bar2.git master")
    end
  end

  it "should fork repository in different project" do
    create_project("kipper", "foo", "foo-desc")
    create_project("kipper", "foo2", "foo2-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      hub("kipper", "fork-repository foo bar foo2 bar2")
      git("kipper", "pull #{ENV['USER']}@#{HUB_HOST}:foo2/bar2.git master")
    end
  end

  it "should track projects related by forking" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      hub("kipper", "fork-repository foo bar foo bar2")
      hub("kipper", "list-forks foo bar").should == "foo/bar\nfoo/bar2\n"
    end
  end

  it "should require read access to fork repository" do
    create_project("kipper", "foo", "foo-desc")
    create_project("kipper", "foo2", "foo2-desc")
    hub("kipper", "create-repository foo bar")

    with_test_project do
      git("kipper", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master")
      lambda { hub("tiger", "fork-repository foo bar foo2 bar2") }.should raise_error
      hub("kipper", "add-permission foo tiger read")
      lambda { hub("tiger", "fork-repository foo bar foo2 bar2") }.should raise_error
      hub("kipper", "add-permission foo2 tiger write")
      lambda { hub("tiger", "fork-repository foo bar foo2 bar2") }.should raise_error
      hub("kipper", "add-permission foo2 tiger admin")
      hub("tiger", "fork-repository foo bar foo2 bar2")
      hub("kipper", "add-permission foo2 tiger admin")      
    end
  end

  it "should remove permission" do
    create_project("kipper", "foo", "foo-desc")
    hub("kipper", "create-repository foo bar")
    hub("kipper", "add-permission foo tiger read")
    hub("kipper", "remove-permission foo tiger")

    with_test_project do
      lambda { git("tiger", "push #{ENV['USER']}@#{HUB_HOST}:foo/bar.git master") }.should raise_error
    end
  end

  it "should add ssh key" do
    hub("kipper", "add-key laptop", "ssh-rsa yabbadabba fdsa")
  end

  it "should list users for admin" do
    hub("kipper", "add-key laptop", "ssh-rsa yabbadabba fdsa")
    users = hub("admin", "list-users").split("\n").map { |l| l.split[0] }
    users.size.should == 1
    users.first.should == "kipper"
  end

  it "should not list users for non-admin" do
    hub("kipper", "add-key laptop", "ssh-rsa yabbadabba fdsa")
    lambda { hub("kipper", "list-users") }.should raise_error
  end

  it "should allow admin to run-as another user" do
    hub("admin", "run-as kipper create-project foo")
    hub("admin", "run-as kipper set-description foo foo-desc")
    projects = list_projects("kipper")
    projects.should == ["foo"]
  end
end
