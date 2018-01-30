module MDP

export TransitionModel, Params, State, Action, Reward, Policy, solve, simulate

mutable struct TransitionModel
    getInitialState::Function
    getNextState::Function
    isEndState::Function
    maxSteps::Int64 #maximum number of steps.  Acts as a safety for runaways
    goToState::Function
end
function TransitionModel(getInitialState::Function, getNextState::Function,
                         isEndState::Function, maxSteps::Int64)
    TransitionModel(getInitialState, getNextState, getNextisEndStateAction, maxSteps, identity)
end

const Policy = Function
const Reward = Float64
const  Params = Any

abstract type State end
abstract type Action end

function simulate(model::TransitionModel,
                  p::Params,
                  policy::Policy,
                  rng::AbstractRNG=MersenneTwister(0);
                  policy_length::Int=typemax(Int),
                  verbose::Bool=false)

    # This function simulates the model for nSteps using the specified policy and
    # returns the total simulation reward
    cum_reward = 0.0
    actions = Action[]

    s = model.getInitialState(rng)
    for i = 1:model.maxSteps
        i > policy_length && break #some policies have length limits
        if verbose
            println("Step: $i of $(model.maxSteps)")
        end
        a = policy(p, s)
        push!(actions, a)   #output actions actually taken
        s, r = model.getNextState(s, a, rng)
        cum_reward += r

        model.isEndState(s) && break
    end

    return cum_reward::Reward, actions::Vector{Action}
end


end # module
