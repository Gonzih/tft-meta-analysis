include("src/pkgs.jl")
include("src/paperhands.jl")
include("src/paperhands_test.jl")

using Main.Paperhands

model = init_bert_model()

log, acclog = load_train_and_test!(model)

plot(log)
plot(acclog)

save_model_to_disk(model)
