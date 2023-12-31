require 'spec_helper'

describe name_from_filename do
    include_examples 'check'

    def self.elements
        [ Element::Form, Element::Link, Element::Cookie, Element::NestedCookie,
          Element::Header ]
    end

    def issue_count_per_element
        {
            Element::Form         => 210,
            Element::Link         => 114,
            Element::Cookie       => 228,
            Element::Header       => 114,
            Element::LinkTemplate => 114,
            Element::NestedCookie => 228
        }
    end

    easy_test
end
