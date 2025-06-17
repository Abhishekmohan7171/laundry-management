export const VALIDATION_RULES = {
    USER: {
      FIRST_NAME: {
        MIN_LENGTH: 2,
        MAX_LENGTH: 50,
      },
      LAST_NAME: {
        MIN_LENGTH: 2,
        MAX_LENGTH: 50,
      },
      PASSWORD: {
        MIN_LENGTH: 8,
        MAX_LENGTH: 128,
        REQUIRE_UPPERCASE: true,
        REQUIRE_LOWERCASE: true,
        REQUIRE_NUMBER: true,
        REQUIRE_SPECIAL_CHAR: true,
      },
      PHONE: {
        PATTERN: /^\+974[0-9]{8}$/, // Qatar phone number format
      },
    },
    SHOP: {
      NAME: {
        MIN_LENGTH: 3,
        MAX_LENGTH: 100,
      },
      DESCRIPTION: {
        MIN_LENGTH: 10,
        MAX_LENGTH: 500,
      },
      PHONE: {
        PATTERN: /^\+974[0-9]{8}$/,
      },
    },
    ORDER: {
      WEIGHT: {
        MIN: 0.1, // kg
        MAX: 50, // kg
      },
      AMOUNT: {
        MIN: 5, // QAR
        MAX: 1000, // QAR
      },
      SPECIAL_INSTRUCTIONS: {
        MAX_LENGTH: 500,
      },
    },
    SERVICE: {
      NAME: {
        MIN_LENGTH: 3,
        MAX_LENGTH: 100,
      },
      DESCRIPTION: {
        MIN_LENGTH: 10,
        MAX_LENGTH: 300,
      },
      PRICE: {
        MIN: 0.1, // QAR
        MAX: 100, // QAR per kg/item
      },
      PROCESSING_TIME: {
        MIN: 1, // hours
        MAX: 168, // hours (1 week)
      },
    },
  } as const;
  
  export const REGEX_PATTERNS = {
    EMAIL: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
    QATAR_PHONE: /^\+974[0-9]{8}$/,
    STRONG_PASSWORD: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    ALPHANUMERIC: /^[a-zA-Z0-9]+$/,
    NUMERIC: /^[0-9]+$/,
    DECIMAL: /^\d+(\.\d{1,2})?$/,
  } as const;
  
  export const ERROR_MESSAGES = {
    REQUIRED: 'This field is required',
    INVALID_EMAIL: 'Please enter a valid email address',
    INVALID_PHONE: 'Please enter a valid Qatar phone number (+974xxxxxxxx)',
    PASSWORD_TOO_SHORT: 'Password must be at least 8 characters long',
    PASSWORD_TOO_WEAK: 'Password must contain uppercase, lowercase, number and special character',
    INVALID_AMOUNT: 'Please enter a valid amount',
    INVALID_WEIGHT: 'Please enter a valid weight',
    FILE_TOO_LARGE: 'File size must be less than 5MB',
    INVALID_FILE_TYPE: 'Invalid file type',
    FIELD_TOO_SHORT: (field: string, min: number) => `${field} must be at least ${min} characters`,
    FIELD_TOO_LONG: (field: string, max: number) => `${field} must be less than ${max} characters`,
  } as const;