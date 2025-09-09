#!/bin/bash
# 386BSD Comprehensive Testing Framework

run_unit_tests() {
    echo "Running unit tests..."
    
    # Test header dependencies
    echo "Testing header compilation..."
    cd usr/src/kernel
    for header in include/sys/*.h include/*.h; do
        if [[ -f "$header" ]]; then
            echo "Testing: $header"
            echo "#include \"$header\"" | gcc -I./include -I./include/sys -I./include/machine -c -x c - -o /dev/null 2>/dev/null || echo "FAILED: $header"
        fi
    done
}

run_integration_tests() {
    echo "Running integration tests..."
    
    # Test build system components
    cd usr/src/kernel
    bmake clean >/dev/null 2>&1
    bmake depend >/dev/null 2>&1 && echo "✅ bmake depend: PASSED" || echo "❌ bmake depend: FAILED"
    
    # Test sample compilation
    bmake clock.kerno >/dev/null 2>&1 && echo "✅ sample compilation: PASSED" || echo "❌ sample compilation: FAILED"
}

run_performance_tests() {
    echo "Running performance tests..."
    
    # Time clean build
    cd usr/src/kernel
    time (bmake clean && bmake depend) 2>&1 | grep real | sed 's/real/Build time:/'
    
    # Check object file generation
    local obj_count=$(find . -name "*.kerno" | wc -l)
    echo "Object files generated: $obj_count"
}

main() {
    case "${1:-all}" in
        unit) run_unit_tests ;;
        integration) run_integration_tests ;;
        performance) run_performance_tests ;;
        all) 
            run_unit_tests
            run_integration_tests  
            run_performance_tests
            ;;
        *) echo "Usage: $0 [unit|integration|performance|all]" ;;
    esac
}

main "$@"
