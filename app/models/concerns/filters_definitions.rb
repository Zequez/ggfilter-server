module FiltersDefinitions
  # extend ActiveSupport::Concern
  #
  # class ExactFilter < FilteringHelpers::BaseFilter
  #   def condition(params)
  #     ["#{column} = ?", params[:value]]
  #   end
  # end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Input: value
    def exact_filter(column, filter)
      ["#{column} = ?", filter[:value]]
    end

    # Input: gt, lt
    def range_filter(column, filter, stores = nil)
      vals = []
      conds = []
      gt = filter[:gt] || filter[:gte]
      lt = filter[:lt] || filter[:lte]

      prefixes = stores ? stores.map{ |s| "#{s}_" } : ['']
      prefixes.each do |prefix|
        store_conds = []
        if gt.kind_of? Numeric
          store_conds << (filter[:gte] ? "#{prefix}#{column} >= ?" : "#{prefix}#{column} > ?")
          vals << gt
        end

        if lt.kind_of? Numeric
          store_conds << (filter[:lte] ? "#{prefix}#{column} <= ?" : "#{prefix}#{column} < ?")
          vals << lt
        end

        store_conds << "#{prefix}#{column} IS NOT NULL"
        conds << "(#{store_conds.join(' AND ')})"
      end

      conds.empty? ? nil : [conds.join(' OR '), *vals]
    end

    def date_range_filter(column, filter)
      vals = []
      conds = []

      gt = filter[:gt] || filter[:gte]
      lt = filter[:lt] || filter[:lte]

      if gt.kind_of? String
        gt = gt.split('-')
        gt[1] ||= 1
        gt[2] ||= 1
        gt.map!(&:to_i)
        gt = Date.civil(gt[0], gt[1], gt[2])
      elsif gt.kind_of? Numeric
        gt = Time.now + gt
      end

      if lt.kind_of? String
        lt = lt.split('-')
        lt[1] ||= -1
        lt[2] ||= -1
        lt.map!(&:to_i)
        lt = Date.civil(lt[0], lt[1], lt[2])
      elsif lt.kind_of? Numeric
        lt = Time.now + lt
      end

      if gt
        conds << (filter[:gte] ? "#{column} >= ?" : "#{column} > ?")
        vals << gt
      end

      if lt
        conds << (filter[:lte] ? "#{column} <= ?" : "#{column} < ?")
        vals << lt
      end

      conds.empty? ? nil : [conds.join(' AND '), *vals]
    end

    # Input: value, "or" ("and" by default)
    def boolean_filter(column, filter)
      val = filter[:value]
      mode = filter[:mode] || 'and'

      # In case we decide to allow string values
      # column_name = column.scan(/\.(.*)/).flatten.last
      # flags_map = send :"#{column_name}_flags"
      # val = val.map{ |v| flags_map[v.to_sym] }.compact.reduce{ |v, t| v & t }

      decompose = ->(flags) do
        vals = []
        n = 1
        (Math.log2(flags).ceil+1).times do
          vals.push(n) if n & flags > 0
          n = n << 1
        end
        vals
      end

      m = ->(v) do
        "(#{column} & #{v} > 0)"
      end


      if val.kind_of?(Fixnum) and val > 0

        if mode == 'xor'
          vals = decompose.call(val)
          if vals.size > 1
            sql = vals.map{ |v, i|
              other = (vals - [v]).map(&m)
              sub_sql = [m.call(v), *other].join(' AND NOT ')
              "(#{sub_sql})"
            }.join(' OR ')
          else
            sql = "(#{column} = #{vals[0]})"
          end
        elsif mode == 'or'
          sql = m.call(val)
        else
          vals = decompose.call(val)
          sql = vals.map{|v| m.call(v) }.join(' AND ')
        end

        sql
      else
        nil
      end
    end

    # Sort by this http://stackoverflow.com/questions/21104366/how-to-get-position-of-regexp-match-in-string-in-postgresql
    # Input: value
    def name_filter(column, filter)
      value = filter[:value].to_s.parameterize.split('-')

      regex = value.map do |v|
        if v =~ /^\d+$/
          roman = RomanNumerals.to_roman(Integer v).downcase
          v = "(#{v}|#{roman})"
        end
        # [[:<:]] begining of a word
        '[[:<:]]' + v + '.*?'
      end.join

      sanitize_sql_array(["name_slug ~ ?", regex])
    end

    def tags_filter(column, filter)
      tags = filter[:tags] || []
      reject = filter[:reject] || []
      mode = filter[:mode] || 'and'
      if tags.empty? && reject.empty?
        nil
      else
        reject_ids = reject.select{ |t| t.kind_of? Fixnum }
        reject_names = reject.select{ |t| t.kind_of? String }
        reject_ids += Tag.ids_by_names(reject_names) unless reject_names.empty?
        reject_ids.uniq!
        reject_ids.map!{ |id| "[,\\[]#{id}[,\\]]" } # [,[] id [,]]
        reject_conditions = reject_ids.map{ |id| "NOT (games.tags ~ '#{id}')" }
        reject_conditions = reject_conditions.join(' AND ')

        ids = tags.select{ |t| t.kind_of? Fixnum }
        names = tags.select{ |t| t.kind_of? String }
        ids += Tag.ids_by_names(names) unless names.empty?
        ids.uniq!
        ids.map!{ |id| "[,\\[]#{id}[,\\]]" } # [,[] id [,]]
        tags_condition = ids.map{ |id| "games.tags ~ '#{id}'" }
        tags_condition = tags_condition.join(mode == 'and' ? ' AND ' : ' OR ')
        tags_condition = "(#{tags_condition})" unless tags_condition.empty?

        [tags_condition, reject_conditions].reject(&:empty?).join(' AND ')
      end
    end

    # def system_requirements_filter(column, filter)
    #   @@videos = begin
    #     syst = Game.pluck(:steam_id, :system_requirements)
    #     # syst = JSON.load(File.read(Rails.root + 'spec/fixtures/system_req_examples.json'))
    #     syst.inject([]) do |arr, value|
    #       s = value[1]
    #       val = ''
    #       val += s[:minimum][:video_card] if s[:minimum] and s[:minimum][:video_card]
    #       val += s[:recommended][:video_card] if s[:recommended] and s[:recommended][:video_card]
    #       a = [value[0], val]
    #       arr.push(a)
    #       arr
    #     end
    #   end
    #
    #   if filter[:value]
    #     query = Regexp.new(filter[:value], 'i')
    #     L query
    #     ids = @@videos.inject([]) do |arr, val|
    #       arr.push(val[0].to_i) if val[1] =~ query
    #       arr
    #     end
    #     L ids.size
    #     where(steam_id: ids)
    #   else
    #     nil
    #   end
    # end
  end
end
