#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_example() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }

    #[test]
    fn test_with_setup() {
        // arrange
        let input = "hello";

        // act
        let result = input.to_uppercase();

        // assert
        assert_eq!(result, "HELLO");
    }

    #[test]
    #[should_panic(expected = "oops")]
    fn test_panic() {
        panic!("oops");
    }
}
