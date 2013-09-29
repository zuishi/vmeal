class CombineItemsInCart < ActiveRecord::Migration
  def up
    # replace multiple items for a single product in a cart with a single item
    Cart.all.each do |cart|
      # count the number of each product in the cart
      sums = cart.line_items.group(:food_id).sum(:quantity)
      sums.each do |food_id, quantity|
        if quantity >1
        # remove individual items
        cart.line_items.where(:food_id=>food_id).delete_all
        # replace with a single item
        cart.line_items.create(:food_id=>food_id, :quantity=>quantity)
        end
      end
    end
  end

  def down
    LineItem.where("quantity>1").each do |line_item|
      # add individual items
      line_item.quantity.times do
      LineItem.create :cart_id=>line_item.cart_id,
      :food_id=>line_item.food_id, :quantity=>1
      end
      # remove original item
      line_item.destroy
    end
   end
end
