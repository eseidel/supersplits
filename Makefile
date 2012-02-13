.PHONY: test

TEST_HARNESS = "./SuperSplits/DerivedData/Super Splits/Build/Products/Debug/TestHarness"
RUNS_DIR = "./SuperSplits/Super SplitsTests/runs"

test:
	$(TEST_HARNESS) $(RUNS_DIR)/6Jan2012-reference.txt $(RUNS_DIR)/6Jan2012.txt > 6Jan2012-actual.txt
