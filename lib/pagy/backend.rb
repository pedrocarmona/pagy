# See Pagy::Backend API documentation: https://ddnexus.github.io/pagy/api/backend
# encoding: utf-8
# frozen_string_literal: true

class Pagy
  # Defines a few generic methods to paginate an ORM collection out of the box,
  # or any collection by overriding pagy_get_items and/or pagy_get_vars in your controller

  # See also the extras if you need specialized methods to paginate Arrays or other collections

  module Backend ; private         # the whole module is private so no problem with including it in a controller

    # Return Pagy object and items
    def pagy(collection, vars={})
      pagy = Pagy.new(pagy_get_vars(collection, vars))
      return pagy, pagy_get_items(collection, pagy)
    end

    # Sub-method called only by #pagy: here for easy customization of variables by overriding
    def pagy_get_vars(collection, vars)
      vars[:count] ||= count_all(collection)
      vars[:page]  ||= params[ vars[:page_param] || VARS[:page_param] ]
      vars
    end

    def count_all(collection)
      if collection.group_values.empty?
        (c = collection.count(:all)).is_a?(Hash) ? c.size : c
      else
        count_all_sql = Arel.sql("COUNT(*) OVER () as count_all")
        collection.reorder(nil).select(count_all_sql).limit(1).first.count_all
      end
    end

    # Sub-method called only by #pagy: here for easy customization of record-extraction by overriding
    def pagy_get_items(collection, pagy)
      # This should work with ActiveRecord, Sequel, Mongoid...
      collection.offset(pagy.offset).limit(pagy.items)
    end

  end
end
