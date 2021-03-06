require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DashboardController do
  describe 'index' do
    before :each do
      @failed = stub('failed nodes')
      Node.stubs(:failed).returns(@failed)

      @silent = stub('silent nodes')
      Node.stubs(:silent).returns(@silent)

      @logs = stub('latest logs')
      Log.stubs(:latest).returns(@logs)
    end

    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end
  end

  describe 'search' do
    before :each do
      @query = 'match'
      @matches = 'matches'
      @parsed = 'parsed'
      @page = '2'
      Node.stubs(:search).returns(@matches)
      SearchParser.stubs(:parse).returns(@parsed)
    end

    describe 'when searching in the node context' do
      def do_get
        get :search, { :q => @query, :page => @page, :context => 'node' }
      end
      
      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should parse the query string' do
        SearchParser.expects(:parse).with(@query).returns(@parsed)
        do_get
      end
      
      it 'should search nodes with conditions from the parsed query string' do
        Node.expects(:search).with do |args|
          args[:conditions] == @parsed
        end
        do_get
      end

      it 'should pass the current page when searching' do
        Node.expects(:search).with do |args|
          args[:page] == @page
        end
        do_get
      end

      it 'should make the query string available to the view' do
        do_get
        assigns[:q].should == @query
      end

      it 'should make search results available to the view' do
        do_get
        assigns[:results].should == @matches
      end
      
      it 'should render the search results page' do
        do_get
        response.should render_template('search')
      end
    end

    describe 'when searching in the log context' do
      before :each do
        Log.stubs(:search).returns(@matches)
      end
      
      def do_get
        get :search, { :q => @query, :page => @page, :context => 'log' }
      end
      
      it 'should be successful' do
        do_get
        response.should be_success
      end

      it 'should parse the query string' do
        SearchParser.expects(:parse).with(@query).returns(@parsed)
        do_get
      end
      
      it 'should search logs with conditions from the parsed query string' do
        Log.expects(:search).with do |args|
          args[:conditions] == @parsed
        end
        do_get
      end

      it 'should pass the current page when searching' do
        Log.expects(:search).with do |args|
          args[:page] == @page
        end
        do_get
      end

      it 'should make the query string available to the view' do
        do_get
        assigns[:q].should == @query
      end

      it 'should make search results available to the view' do
        do_get
        assigns[:results].should == @matches
      end
      
      it 'should render the search results page' do
        do_get
        response.should render_template('search')
      end
    end
    
    it 'should search for nodes if no context given' do
      Node.expects(:search).returns(@matches)
      get :search, { :q => @query, :page => @page }
    end
    
    it 'should search for nodes if given an unknown context' do
      Node.expects(:search).returns(@matches)
      get :search, { :q => @query, :page => @page, :context => 'nothing' }
    end
  end
end
