class DashboardsController < ApplicationController
  # before_action :authenticate_user!
  # require_dependency 'services/node_client_service'

  def user_profile_data
    kuri_list = ["0x627D0A5ff92c05EB1Ba450887E835A6020E26e69" ]
    user_address  = params[:address] #"0xf4408b493df70a9857DFe8DAef5f4cCe4999A761"

    if user_address
      puts "Initializing Client"
      client = NodeClientService.new.new_client

      kuri_abi = JSON.load(File.open('../contract_abi.json'))
      kuri_name = "Rosca"
      # kuri_address = kuri_list.first

      puts "Initializing INR Token"
      inr_token_address = "0x42F253D3E3Ee7Dd8676DE6075c15A252879FA9cF"
      inr_token_abi = JSON.load(File.open('../inr_token_abi.json'))
      inr_token_name = "Rosca"

      inr_token = ContractService.new(inr_token_name, inr_token_address, inr_token_abi)

      puts "Calculating Balance"
      balance = client.call(inr_token.contract, "balanceOf",user_address)
      points = 420
      username = nil

      kuri_data = []
      kuri_list.each_with_index do |kuri_address, i|
        puts "Iniializing. Inside Kuri: #{kuri_address}"
        kuri = ContractService.new(kuri_name, kuri_address, kuri_abi)

        username ||= client.call(kuri.contract, 'username',user_address)
        
        won_round = client.call(kuri.contract, "participantWonRound", user_address)        
        if won_round >= 0
          prize_won = 0
        else
          prize_won = client.call(kuri.contract, "prizeMoneyforRound",won_round)
        end
        contribution = client.call(kuri.contract, "userContributions",user_address)

        slots = client.call(kuri.contract, "slots")
        truth_table = { periods: slots }

        participants = client.call(kuri.contract, "getParticipants")

        current_round = client.call(kuri.contract, "currentRound")
        participants_data = []
        puts "Generating Truth Table"
        participants.each do |participant_address|
          participant_name = client.call(kuri.contract, 'username',participant_address)
          puts "====> Participant: #{participant_name}"
          participant_won_round = client.call(kuri.contract, "participantWonRound",user_address)                
          slot_data = []
          (1..slots).each do |slot|
            puts "========> Generating Round: #{slot}"
      
            status = 'PENDING'
            if slot <= current_round
              paid_round = client.call(kuri.contract, "hasPaidRound",participant_address, slot)
              if paid_round
                status = 'PAID'
                status = 'WON' if participant_won_round == slot
              else
                status = 'DEFAULT' if slot < current_round
              end
            end
            slot_data << status
          end
          participants_data << { name: participant_name, statuses: slot_data }
        end

        truth_table[:participants] = participants_data
        kuri_data << {id: i, contribution: contribution, prize: prize_won, truthTable: truth_table}
      end

      data = {
        user: {
          id: 1,
          name: username,
          balance: balance,
          points: points
        },
        kuris: kuri_data
      }

      render json: data
    else
      render plain: 'User address is missing' 
    end
    # data = {
    #       truthTable: {
    #         participants: [
    #           {
    #             name: "anjal",
    #             statuses: ['COMPLETED', 'COMPLETED', 'COMPLETED', 'PENDING', 'PENDING']
    #           },
    #           {
    #             name: "nihal",
    #             statuses: ['COMPLETED', 'COMPLETED', 'COMPLETED', 'PENDING', 'PENDING']
    #           }
    #         ]
    #       }
    #     }    
    #   ]
    # }
  end
end