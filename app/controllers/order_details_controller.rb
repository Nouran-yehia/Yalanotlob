class OrderDetailsController < ApplicationController

    def get_details
        @ordersDetails = OrderDetail.where(order_id: $orderId, user_id: current_user.id)
  
        @acceptedUsers = []
        Invitation.where(order_id: $orderId, status: "accepted").find_each do |invitation|
            @acceptedUsers << invitation.user 
        end

        @allUsers = []
        @allInvitations = []
        Invitation.where(order_id: $orderId).find_each do |invitation|
            @allInvitations << invitation
            @allUsers << invitation.user
        end    
    
        @acceptedCount = @acceptedUsers.count
        @allCount = @allUsers.count

        @userOrder = false
        if $order.user_id == current_user.id
            @userOrder = true
        end    

        return @ordersDetails, @acceptedCount, @acceptedUsers, @allCount, @allUsers, @allInvitations, @userOrder
    end
    
    def show
        $orderId = params[:id]
        $order = Order.find($orderId)
        redirect_to new_order_detail_path
    end

    def new
        get_details()
        @order = Order.find_by(user_id: current_user.id, id: $orderId).nil?
        @orderDetails = OrderDetail.new
        unless @acceptedUsers.include?(current_user) && @allUsers.include?(current_user)
            if @order
                flash[:error] = "You are not allowed to view this order_details"
            end
        end
    end

    def create
        @orderDetails = OrderDetail.new
        @orderDetails.order_id = $orderId
        @orderDetails.user_id = current_user.id
        @orderDetails.item = params[:order_detail][:item]
        @orderDetails.amount = params[:order_detail][:amount]
        @orderDetails.price = params[:order_detail][:price]
        @orderDetails.comment = params[:order_detail][:comment]
 
        if(@orderDetails.save)
            get_details()
            redirect_to new_order_detail_path 
        else    
            get_details()
            render :new
        end
    end

    def destroy
        @orderDetails = OrderDetail.find(params[:id])
        @orderDetails.delete
        redirect_to new_order_detail_path
    end

    private
    def details_params
      params.require(:order_detail).permit(:item, :amount, :price, :comment)
    end
    
end
