.PHONY: test

TEST_HARNESS = "./SuperSplits/DerivedData/Super Splits/Build/Products/Debug/TestHarness"
RUNS_DIR = "./SuperSplits/Super SplitsTests/runs"

compile:
	pushd SuperSplits; xcodebuild -target TestHarness -configuration Debug; popd

check: compile
	$(TEST_HARNESS) $(RUNS_DIR)/6Jan2012-reference.txt $(RUNS_DIR)/6Jan2012.txt > 6Jan2012-actual.txt
	@diff -U 7 6Jan2012-expected.txt 6Jan2012-actual.txt

accept:
	@mv 6Jan2012-actual.txt 6Jan2012-expected.txt
