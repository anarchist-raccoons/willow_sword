module WillowSword
  class DcCrosswalk
    attr_reader :metadata, :terms, :translated_terms, :singular
    def initialize(src_file)
      @src_file = src_file
      @metadata = {}
    end

    def terms
      %w(abstract accessRights accrualMethod accrualPeriodicity
        accrualPolicy alternative audience available bibliographicCitation
        conformsTo contributor coverage created creator date dateAccepted
        dateCopyrighted dateSubmitted description educationLevel extent
        format hasFormat hasPart hasVersion identifier instructionalMethod
        isFormatOf isPartOf isReferencedBy isReplacedBy isRequiredBy issued
        isVersionOf language license mediator medium modified provenance
        publisher references relation replaces requires rights rightsHolder
        source spatial subject tableOfContents temporal title type valid)
    end

    def translated_terms
      {
        'created' =>'date_created',
        'rights' => 'rights_statement',
        'relation' => 'related_url',
        'type' => 'resource_type',
        
        # these exist in dog_biscuits
        'available' => 'date_available',
        'format' => 'dc_format',
        'accepted' => 'date_accepted',
        'dateCopyrighted' => 'date_copyrighted',
        'dateSubmitted' => 'date_submitted',
        'valid' => 'date_valid',
        'issued' => 'date_issued',
      }
    end

    def singular
      %w(rights)
    end

    def map_xml
      return @metadata unless @src_file.present?
      return @metadata unless File.exist? @src_file
      f = File.open(@src_file)
      doc = Nokogiri::XML(f)
      # doc = Nokogiri::XML(@xml_metadata)
      doc.remove_namespaces!
      terms.each do |term|
        values = []
        doc.xpath("//#{term}").each do |t|
          values << t.text if t.text.present?
        end
        key = translated_terms.include?(term) ? translated_terms[term] : term
        values = values.first if values.present? && singular.include?(term)
        @metadata[key.to_sym] = values unless values.blank?
      end
      f.close
    end
  end
end

