import 'package:flutter_test/flutter_test.dart';

import 'package:find_it/core/services/auth_validation.dart';

void main() {
  group('AuthValidation', () {
    group('validateRegistration', () {
      test('accepts valid registration details', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: 'Computer Science',
          phoneNumber: '0712345678',
          acceptTerms: true,
        );
        expect(error, isNull);
      });

      test('rejects empty name', () {
        final error = AuthValidation.validateRegistration(
          name: ' ',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: 'Computer Science',
          phoneNumber: '0712345678',
        );
        expect(error, 'Name is required.');
      });

      test('rejects short password', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: '123',
          department: 'Computer Science',
          phoneNumber: '0712345678',
        );
        expect(error, 'Password must be at least 6 characters.');
      });

      test('rejects invalid email', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'not-an-email',
          password: 'StrongPass123',
          department: 'Computer Science',
          phoneNumber: '0712345678',
        );
        expect(error, 'Please enter a valid email address.');
      });

      test('rejects empty email', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: '',
          password: 'StrongPass123',
          department: 'Computer Science',
          phoneNumber: '0712345678',
        );
        expect(error, 'Please enter your email address.');
      });

      test('rejects mismatched passwords', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          confirmPassword: 'DifferentPass',
          department: 'Computer Science',
          phoneNumber: '0712345678',
        );
        expect(error, 'Passwords do not match.');
      });

      test('rejects empty department', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: '',
          phoneNumber: '0712345678',
        );
        expect(error, 'Department is required.');
      });

      test('rejects invalid phone', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: 'CS',
          phoneNumber: '12',
        );
        expect(error, 'Please enter a valid phone number.');
      });

      test('rejects empty phone', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: 'CS',
          phoneNumber: '',
        );
        expect(error, 'Please enter your phone number.');
      });

      test('rejects when acceptTerms is not true', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: 'CS',
          phoneNumber: '0712345678',
          acceptTerms: false,
        );
        expect(error, 'Please accept the terms and conditions.');
      });

      test('accepts when acceptTerms is true', () {
        final error = AuthValidation.validateRegistration(
          name: 'Ava',
          email: 'ava@example.com',
          password: 'StrongPass123',
          department: 'CS',
          phoneNumber: '0712345678',
          acceptTerms: true,
        );
        expect(error, isNull);
      });
    });

    group('validateLogin', () {
      test('accepts valid login', () {
        final error = AuthValidation.validateLogin(
          email: 'ava@example.com',
          password: 'password123',
        );
        expect(error, isNull);
      });

      test('rejects invalid email', () {
        final error = AuthValidation.validateLogin(
          email: 'bad-email',
          password: 'password123',
        );
        expect(error, 'Please enter a valid email address.');
      });

      test('rejects empty password', () {
        final error = AuthValidation.validateLogin(
          email: 'ava@example.com',
          password: '',
        );
        expect(error, 'Please enter your password.');
      });

      test('rejects short password', () {
        final error = AuthValidation.validateLogin(
          email: 'ava@example.com',
          password: '123',
        );
        expect(error, 'Password must be at least 6 characters.');
      });
    });

    group('validateLoginEmail', () {
      test('accepts valid email', () {
        expect(AuthValidation.validateLoginEmail('user@test.com'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validateLoginEmail(null), 'Please enter your email address.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validateLoginEmail(''), 'Please enter your email address.');
      });

      test('rejects whitespace only', () {
        expect(AuthValidation.validateLoginEmail('   '), 'Please enter your email address.');
      });

      test('rejects invalid format', () {
        expect(AuthValidation.validateLoginEmail('not-email'), 'Please enter a valid email address.');
      });

      test('rejects email without domain', () {
        expect(AuthValidation.validateLoginEmail('user@'), 'Please enter a valid email address.');
      });

      test('rejects email without TLD', () {
        expect(AuthValidation.validateLoginEmail('user@test'), 'Please enter a valid email address.');
      });
    });

    group('validateLoginPassword', () {
      test('accepts valid password', () {
        expect(AuthValidation.validateLoginPassword('password123'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validateLoginPassword(null), 'Please enter your password.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validateLoginPassword(''), 'Please enter your password.');
      });

      test('rejects short password', () {
        expect(AuthValidation.validateLoginPassword('12345'), 'Password must be at least 6 characters.');
      });
    });

    group('validateRegistrationPassword', () {
      test('accepts valid password', () {
        expect(AuthValidation.validateRegistrationPassword('StrongPass123'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validateRegistrationPassword(null), 'Please enter a password.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validateRegistrationPassword(''), 'Please enter a password.');
      });

      test('rejects short password', () {
        expect(AuthValidation.validateRegistrationPassword('12'), 'Password must be at least 6 characters.');
      });
    });

    group('validateConfirmPassword', () {
      test('accepts matching passwords', () {
        expect(AuthValidation.validateConfirmPassword('pass1', 'pass1'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validateConfirmPassword(null, 'pass'), 'Please confirm your password.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validateConfirmPassword('', 'pass'), 'Please confirm your password.');
      });

      test('rejects mismatched', () {
        expect(AuthValidation.validateConfirmPassword('pass1', 'pass2'), 'Passwords do not match.');
      });
    });

    group('validatePhone', () {
      test('accepts valid phone', () {
        expect(AuthValidation.validatePhone('0712345678'), isNull);
      });

      test('accepts phone with dashes', () {
        expect(AuthValidation.validatePhone('071-234-5678'), isNull);
      });

      test('accepts phone with plus prefix', () {
        expect(AuthValidation.validatePhone('+1234567890'), isNull);
      });

      test('accepts phone with spaces', () {
        expect(AuthValidation.validatePhone('071 234 5678'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validatePhone(null), 'Please enter your phone number.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validatePhone(''), 'Please enter your phone number.');
      });

      test('rejects too short', () {
        expect(AuthValidation.validatePhone('12'), 'Please enter a valid phone number.');
      });
    });

    group('validateName', () {
      test('accepts valid name', () {
        expect(AuthValidation.validateName('John Doe'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validateName(null), 'Please enter your full name.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validateName(''), 'Please enter your full name.');
      });

      test('rejects whitespace only', () {
        expect(AuthValidation.validateName('   '), 'Please enter your full name.');
      });
    });

    group('validateDepartment', () {
      test('accepts valid department', () {
        expect(AuthValidation.validateDepartment('Computer Science'), isNull);
      });

      test('rejects null', () {
        expect(AuthValidation.validateDepartment(null), 'Please enter your department.');
      });

      test('rejects empty', () {
        expect(AuthValidation.validateDepartment(''), 'Please enter your department.');
      });

      test('rejects whitespace only', () {
        expect(AuthValidation.validateDepartment('   '), 'Please enter your department.');
      });
    });

    group('validateEmailForReset', () {
      test('accepts valid email', () {
        expect(AuthValidation.validateEmailForReset('user@test.com'), isNull);
      });

      test('rejects invalid email', () {
        expect(AuthValidation.validateEmailForReset('not-email'), 'Please enter a valid email address.');
      });
    });
  });
}
