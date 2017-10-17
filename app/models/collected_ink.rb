class CollectedInk < ApplicationRecord

  KINDS = %w(bottle sample cartridge)

  validates :kind, inclusion: { in: KINDS, allow_blank: true }
  validates :brand_name, length: { in: 1..100 }
  validates :ink_name, length: { in: 1..100 }
  validates :line_name, length: { in: 1..100, allow_blank: true }

  validate :unique_constraint

  before_save :simplify

  belongs_to :user

  def self.field_by_term(field, term, user)
    relation = where("#{field} <> ?", '')
    if user
      relation = relation.where("private = ? OR user_id = ?", false, user.id)
    else
      relation = relation.where(private: false)
    end
    relation.where("LOWER(#{field}) LIKE ?", "%#{term.downcase}%").group(field).order(field).pluck(field)
  end

  def self.unique_for_brand(simplified_brand_name)
    unique_inks = where(simplified_brand_name: simplified_brand_name)
      .group(:simplified_ink_name)
      .pluck(:simplified_ink_name)
    unique_inks = unique_inks.map do |ui|
      CollectedInk.find_by(simplified_brand_name: simplified_brand_name, simplified_ink_name: ui)
    end
    unique_inks.sort do |ci1, ci2|
      if ci1.popular_line_name == ci2.popular_line_name
        ci1.popular_ink_name <=> ci2.popular_ink_name
      else
        ci1.popular_line_name <=> ci2.popular_line_name
      end
    end
  end

  def self.alphabetical
    order("brand_name, line_name, ink_name")
  end

  def self.brand_count
    reorder(:simplified_brand_name).group(:simplified_brand_name).pluck(:simplified_brand_name).size
  end

  def self.unique_brands
    display_name_select = "(select brand_name from collected_inks as ci
     	where ci.simplified_brand_name = collected_inks.simplified_brand_name
     	group by ci.brand_name order by count(*) desc limit 1
    )"
    select("simplified_brand_name, #{display_name_select} as popular_name")
    .group(:simplified_brand_name)
    .order(:simplified_brand_name)
  end

  def self.unique_inks_per_brand(name)
    # Ignore the simplified_line_name here as it's unlikely that a single brand will have the same
    # ink name in two different lines.
    where(simplified_brand_name: name).group(:simplified_ink_name).count.size
  end

  def self.brands
    reorder(:brand_name).group(:brand_name).pluck(:brand_name)
  end

  def self.bottles
    where(kind: "bottle")
  end

  def self.bottle_count
    bottles.count
  end

  def self.samples
    where(kind: "sample")
  end

  def self.sample_count
    samples.count
  end

  def self.cartridges
    where(kind: "cartridge")
  end

  def self.cartridge_count
    cartridges.count
  end

  def popular_brand_name
    self.class.where(simplified_brand_name: simplified_brand_name)
    .group(:brand_name)
    .order(:brand_name)
    .limit(1)
    .pluck(:brand_name)
    .first
  end

  def popular_line_name
    self.class.where(simplified_brand_name: simplified_brand_name, simplified_line_name: simplified_line_name)
    .group(:line_name)
    .order(:line_name)
    .limit(1)
    .pluck(:line_name)
    .first
  end

  def popular_ink_name
    self.class.where(simplified_brand_name: simplified_brand_name, simplified_ink_name: simplified_ink_name)
    .group(:ink_name)
    .order(:ink_name)
    .limit(1)
    .pluck(:ink_name)
    .first
  end

  def count
    self.class.where(simplified_brand_name: simplified_brand_name, simplified_ink_name: simplified_ink_name).count
  end

  def name
    "#{brand_name} #{line_name} #{ink_name}"
  end

  def brand_name=(value)
    super(value.strip)
  end

  def line_name=(value)
    super(value.strip)
  end

  def ink_name=(value)
    super(value.strip)
  end

  private

  def unique_constraint
    rel = self.class.where(
      "LOWER(brand_name) = ? AND LOWER(line_name) = ? AND LOWER(ink_name) = ?",
      brand_name.to_s.downcase,
      line_name.to_s.downcase,
      ink_name.to_s.downcase
    ).where(user_id: user_id).where(kind: kind)
    rel = rel.where("id <> ?", id) if persisted?
    errors.add(:ink_name, "Duplicate!") if rel.exists?
  end

  def simplify
    Simplifier.for_collected_ink(self).run
  end
end
