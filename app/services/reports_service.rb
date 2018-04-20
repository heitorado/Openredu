require 'csv'

class ReportsService
    def initialize(environment)
        @environment = environment
    end

    def create_report
        courses = @environment.courses
        spaces = courses.map {|c| c.spaces }.flatten
        subjects = spaces.map {|s| s.subjects }.flatten
        exercises = subjects.map {|s| s.lectures.exercises }.flatten
        report = [
            [
                'Identificação do Aluno', 
                'Nome do Aluno', 
                'Idade do Aluno', 
                'Nota do exercicio',
                'Identificação do Exercicio',
                'Titulo do Exercicio(Assunto)',
                'Identificação da Disciplina',
                'Nome da Disciplina',
                'Turno',
                'Identificação do Professor',
                'Nome do Professor',
                'Identificação da Turma',
                'Nome da Turma'
            ]
        ]
        exercises.each do |exercise| 
            users = exercise.subject.space.students
            users.each do |user|
                report_row = []
                if exercise.lectureable.finalized_by? user
                    result = exercise.lectureable.result_for user
                    report_row << user.id
                    report_row << user.display_name
                    report_row << (Date.today - user.birthday).to_i / 365
                    report_row << result.grade.to_s
                    report_row << exercise.id
                    report_row << exercise.name
                    report_row << exercise.subject.space.id
                    report_row << exercise.subject.space.name
                    report_row << exercise.subject.space.turn
                    report_row << exercise.owner.id
                    report_row << exercise.owner.display_name
                    report_row << exercise.subject.space.course.id
                    report_row << exercise.subject.space.course.name
                    report << report_row
                end
            end
        end
        csv_string = CSV.generate do |csv|
            report.each do |row|
                csv << row
            end
        end
    end
end