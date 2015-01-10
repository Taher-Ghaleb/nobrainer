module NoBrainer::Criteria::Preload
  extend ActiveSupport::Concern

  included { criteria_option :preload, :merge_with => :append_array }

  def preload(*values)
    chain({:preload => values}, :copy_cache_from => self)
  end

  def merge!(criteria, options={})
    super.tap do
      # If we already have some cached documents, and we need to so some eager
      # loading, then we it now. It's easier than doing it lazily.
      if self.cached? && criteria.options[:preload].present?
        perform_preloads(@cache)
      end
    end
  end

  def each(options={}, &block)
    return super unless should_preloads? && !options[:no_preloading] && block

    docs = []
    super(options.merge(:no_preloading => true)) { |doc| docs << doc }
    perform_preloads(docs)
    docs.each(&block)
    self
  end

  private

  def should_preloads?
    @options[:preload].present? && !raw?
  end

  def get_one(criteria)
    super.tap { |doc| perform_preloads([doc]) }
  end

  def perform_preloads(docs)
    if should_preloads? && docs.present?
      NoBrainer::Document::Association::EagerLoader.new.eager_load(docs, @options[:preload])
    end
  end
end
