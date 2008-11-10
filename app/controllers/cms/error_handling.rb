module Cms
  module ErrorHandling
    def self.included(controller)
      controller.class_eval do
        rescue_from Exception, :with => :cms_server_error
        rescue_from Cms::Errors::AccessDenied, :with => :cms_access_denied
        rescue_from ActiveRecord::RecordNotFound, :with => :cms_not_found
      end
    end

    def cms_not_found(exception)
      handler_error_with_cms_page('/system/not_found', exception)
    end

    def cms_access_denied(exception)
      handler_error_with_cms_page('/system/access_denied', exception)
    end

    def cms_server_error(exception)
      handler_error_with_cms_page('/system/server_error', exception)
    end        
    
    private
    def handler_error_with_cms_page(error_page_path, exception)
      Rails.logger.warn "Exception: #{exception.message}\n"
      Rails.logger.warn "#{exception.backtrace.join("\n")}\n"
      if @page = Page.find_live_by_path(error_page_path)
        @exception = exception
        render :layout => @page.layout, :template => 'cms/content/show'
      else
        Rails.logger.warn "There is no page at #{error_page_path}"
        render :text => "<h1>Missing Error Page</h1><p>There should be an error page at #{error_page_path}.  The original error is '#{exception.message}'</p>"
      end      
    rescue Exception => e
      Rails.logger.error "CMS EXCEPTION HANDLING FAIL: #{e.message}\n"
      Rails.logger.error e.backtrace.join("\n")
      render :text => exception.message
    end    
        
  end
end