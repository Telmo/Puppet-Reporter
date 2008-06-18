require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  before(:each) do
    @report = Report.new
  end

  describe 'when validating' do    
    it "should be valid" do
      @report.should be_valid
    end
  end
  
  describe 'associations' do
    it 'can have a node' do
      @report.node.should be_nil
    end
  end
  
  describe 'as a class' do
    describe 'loading report data from YAML files' do
      before :each do
        @files = [ '/tmp/1', '/tmp/2', '/tmp/3' ]
        @report = Report.new
        @files.each do |file| 
          File.stubs(:read).with(file).returns("#{file} contents")
          Report.stubs(:from_yaml).with("#{file} contents").returns(@report)
        end
      end
      
      it 'should require at least one file name' do
        lambda { Report.import_from_yaml_files }.should raise_error(ArgumentError)
      end
      
      it 'should read each file' do
        @files.each {|file| File.expects(:read).with(file).returns("#{file} contents") }
        Report.import_from_yaml_files(@files)
      end
      
      it 'should create a report from the contents of each file' do
        @files.each do |file| 
          File.stubs(:read).with(file).returns("#{file} contents")
          Report.expects(:from_yaml).with("#{file} contents")
        end
        Report.import_from_yaml_files(@files)
      end
      
      describe 'if a file cannot be read' do
        before :each do
          File.stubs(:read).with(@files[1]).raises(Errno::ENOENT)          
        end
        
        it 'should not fail' do
          lambda { Report.import_from_yaml_files(@files) }.should_not raise_error               
        end
        
        it 'should emit a warning about the file' do
          Report.expects(:warn)
          Report.import_from_yaml_files(@files)
        end
        
        it 'should continue to process other files' do
          Report.expects(:from_yaml).with("#{@files.last} contents")
          Report.import_from_yaml_files(@files)
        end
      end
      
      describe 'if a report cannot be created from the contents of a file' do        
        before :each do
          Report.stubs(:from_yaml).with("#{@files[1]} contents").raises(RuntimeError)
        end

        it 'should not fail' do
          lambda { Report.import_from_yaml_files(@files) }.should_not raise_error               
        end        
        
        it 'should emit a warning about the file' do
          Report.expects(:warn)
          Report.import_from_yaml_files(@files)
        end
        
        it 'should continue to process other files' do
          Report.expects(:from_yaml).with("#{@files.last} contents")
          Report.import_from_yaml_files(@files)
        end
      end
      
      it 'should return a list of the files which had reports successfully created' do
        File.stubs(:read).with(@files[1]).raises(Errno::ENOENT)          
        Report.import_from_yaml_files(@files).first.should == [ @files.first, @files.last ]
      end
      
      it 'should return a list of the files which did not have reports successfully created' do
        File.stubs(:read).with(@files[1]).raises(Errno::ENOENT)          
        Report.import_from_yaml_files(@files).last.should == [ @files[1] ]
      end
    end
    
    describe 'creating reports from YAML' do
      it 'should require a string of data'
      it 'should reinstantiate a puppet report from the YAML string'
      it 'should create a new Report'
      it 'should set the Report details from the original YAML string'
      it 'should set the timestamp of the Report to the timestamp of the Puppet report'
      it 'should look up the Node for the Report'
      it 'should create a Node for the Report if no matching node is found'
      it 'should return the created Report'
    end
  end
end
