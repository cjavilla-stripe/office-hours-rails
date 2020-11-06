class OrdersController < ApplicationController
  def index
    orders = Order.all
    render json: orders
  end

  def show
    # single item
  end

  def new
    # form for creating an item
  end

  def create
    # creates an item
    @order = Order.new(order_params)
    if @order.save
      render json: @order
    else
      render json: @order.errors
    end
  end

  def edit
    # form for editing an item
  end

  def update
    # change / modify or update an existing item
  end

  def destroy
    # delete an item
  end

  private

  def order_params
    # {
    #   order: {
    #     status: "paid",
    #     paid_at: 123456789,
    #     stripe_id: 'pi_234abc',
    #   }
    # }
    params.require(:order).permit(:status, :paid_at, :stripe_id)
  end
end
