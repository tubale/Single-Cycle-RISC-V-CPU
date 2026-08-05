import shutil
import subprocess
import time

# ==========================================================
# Test List
# ==========================================================

tests = [

    {
        "name": "ADD_01",
        "program": "programs/arithmetic/add.mem",
        "checks": [
            (1, "00000005"),
            (2, "00000007"),
            (3, "0000000C"),
        ],
    },

    {
        "name": "SUB_01",
        "program": "programs/arithmetic/sub.mem",
        "checks": [
            (1, "0000000A"),
            (2, "00000003"),
            (3, "00000007"),
        ],
    },

]

# ==========================================================
# Compile Design
# ==========================================================

print("\n")
print("=" * 70)
print("          RISC-V SINGLE-CYCLE CPU REGRESSION")
print("=" * 70)
print()

compile_result = subprocess.run(
    ["make"],
    capture_output=True,
    text=True
)

if compile_result.returncode != 0:
    print("Compilation Failed!\n")
    print(compile_result.stdout)
    print(compile_result.stderr)
    quit()

print("Compilation Successful!\n")

# ==========================================================
# Run Tests
# ==========================================================

passed = 0
failed = 0

total_start = time.perf_counter()

for index, test in enumerate(tests, start=1):

    print("=" * 70)
    print(f"[{index:02}/{len(tests):02}] Running {test['name']}")
    print("=" * 70)

    # ------------------------------------------------------
    # Copy test program
    # ------------------------------------------------------

    shutil.copy(
        test["program"],
        "program.mem"
    )

    # ------------------------------------------------------
    # Build command line arguments
    # ------------------------------------------------------

    args = ["vvp", "sim.out"]

    for i, (reg, value) in enumerate(test["checks"], start=1):

        args.append(f"+REG{i}={reg}")
        args.append(f"+VALUE{i}={value}")

    # ------------------------------------------------------
    # Run Simulation
    # ------------------------------------------------------

    start = time.perf_counter()

    result = subprocess.run(
        args,
        capture_output=True,
        text=True
    )

    elapsed = time.perf_counter() - start

    # ------------------------------------------------------
    # Print simulation output
    # ------------------------------------------------------

    print(result.stdout)

    # ------------------------------------------------------
    # Determine PASS / FAIL
    # ------------------------------------------------------

    if "TEST PASSED" in result.stdout:

        passed += 1

        print(f"{test['name']} PASSED ({elapsed:.3f} sec)\n")

    else:

        failed += 1

        print(f"{test['name']} FAILED ({elapsed:.3f} sec)\n")

total_time = time.perf_counter() - total_start

# ==========================================================
# Final Summary
# ==========================================================

print()
print("=" * 70)
print("                    REGRESSION SUMMARY")
print("=" * 70)

print(f"Tests Passed : {passed}")
print(f"Tests Failed : {failed}")
print(f"Total Tests  : {len(tests)}")

if len(tests) > 0:
    print(f"Pass Rate    : {passed/len(tests)*100:.1f}%")

print(f"Total Time   : {total_time:.3f} sec")

print("=" * 70)

if failed == 0:
    print("ALL TESTS PASSED")
else:
    print("SOME TESTS FAILED")

print("=" * 70)